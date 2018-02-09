package org.batfish.geometry;

import com.google.common.base.Objects;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.BitSet;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.Random;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import javax.annotation.Nullable;
import org.batfish.datamodel.Configuration;
import org.batfish.datamodel.DataPlane;
import org.batfish.datamodel.Edge;
import org.batfish.datamodel.FilterResult;
import org.batfish.datamodel.Flow;
import org.batfish.datamodel.FlowDisposition;
import org.batfish.datamodel.FlowHistory;
import org.batfish.datamodel.FlowTrace;
import org.batfish.datamodel.FlowTraceHop;
import org.batfish.datamodel.ForwardingAction;
import org.batfish.datamodel.HeaderSpace;
import org.batfish.datamodel.Interface;
import org.batfish.datamodel.IpAccessList;
import org.batfish.datamodel.IpAccessListLine;
import org.batfish.datamodel.LineAction;
import org.batfish.datamodel.Prefix;
import org.batfish.datamodel.TcpFlags;
import org.batfish.datamodel.answers.AnswerElement;
import org.batfish.datamodel.collections.FibRow;
import org.batfish.datamodel.collections.NodeInterfacePair;
import org.batfish.datamodel.pojo.Environment;
import org.batfish.main.Batfish;
import org.batfish.symbolic.utils.Tuple;

/*
 * An edge-labelled graph that captures the forwarding behavior of
 * all packets. Packets are slice into equivalence classes that get
 * refined as new forwarding and ACL rules get added to the data structure.
 *
 * <p>Nodes are split into two categories: routers and ACL nodes. ACL nodes are
 * treated as special to make it easier to determine the cause of a packet drop.
 * It is also convenient to deal with ACLs in a uniform way, ACL entries are just
 * forwarding rules that either forward to a special "drop" node, or out the interface
 * to the neighbor.</p>
 *
 * <p>There is a special drop node that all routers can forward to, for example,
 * if they have a null route</p>
 *
 * <p>The equivalence classes are represented by multidimensional hyperrectangles.
 * When a new rule is added, we find all overlapping rectangles and refine the space
 * by splitting into more rules. Updating the edge-labelled graph is done in the
 * same was as with delta-net.</p>
 *
 *
 * List of possible further optimizations:
 *
 * - Use a persistent map for _owner to avoid all the deep copies and
 *   reduce space consumption dramatically.
 *
 * - We only need to keep all the rules if we want to support remove.
 *   otherwise, we can just keep a single highest priority rule.
 *
 * - There are better datastructures than KD trees for collision detection.
 *   Are any easy to implement?
 *
 */
public class ForwardingGraph {

  private static int ACCEPT_FLAG = 0;
  private static int DROP_FLAG = 1;
  private static int DROP_ACL_FLAG = 2;
  private static int DROP_ACL_IN_FLAG = 3;
  private static int DROP_ACL_OUT_FLAG = 4;
  private static int DROP_NULL_ROUTE_FLAG = 5;
  private static int DROP_NO_ROUTE_FLAG = 6;

  // Equivalence classes indexed from 0
  private ArrayList<HyperRectangle> _ecs;

  // Edges labelled with equivalence classes, indexed by equivalence class
  private BitSet[] _labels;

  // EC index to graph node, to set of rules for that EC on that node.
  private ArrayList<Map<GraphNode, PriorityQueue<Rule>>> _ownerMap;

  // Efficient searching for equivalence class overlap
  private KDTree _kdtree;

  // Map from routers to graph nodes in this extended graph
  private Map<String, GraphNode> _nodeMap;

  // Map from ACLs to graph nodes in this extended graph
  private Map<String, AclGraphNode> _aclMap;

  // Map from interfaces to links in this extened graph
  private Map<NodeInterfacePair, GraphLink> _linkMap;

  // All the nodes in the graph
  private List<GraphNode> _allNodes;

  // All the links in the graph
  private List<GraphLink> _allLinks;

  // Adjacency list for the graph indexed by GraphNode index
  private ArrayList<List<GraphLink>> _adjacencyLists;

  private Batfish _batfish;

  /*
   * Construct the edge-labelled graph from the configurations
   * and the dataplane generated by Batfish
   */
  public ForwardingGraph(Batfish batfish, DataPlane dp) {
    long t = System.currentTimeMillis();
    _batfish = batfish;
    initGraph(batfish, dp);

    HyperRectangle fullRange = GeometricSpace.fullSpace();
    fullRange.setAlphaIndex(0);
    _ecs = new ArrayList<>();
    _ecs.add(fullRange);
    _ownerMap = new ArrayList<>();
    _kdtree = new KDTree(GeometricSpace.NUM_FIELDS);
    _kdtree.insert(fullRange);

    // initialize the labels
    _labels = new BitSet[_allLinks.size()];
    for (GraphLink link : _allLinks) {
      _labels[link.getIndex()] = new BitSet();
    }

    // initialize owners
    Map<GraphNode, PriorityQueue<Rule>> map = new HashMap<>();
    _allNodes.forEach(r -> map.put(r, new PriorityQueue<>()));
    _ownerMap.add(map);

    // add the FIB rules
    List<Rule> rules = new ArrayList<>();
    for (Entry<String, Map<String, SortedSet<FibRow>>> entry : dp.getFibs().entrySet()) {
      String router = entry.getKey();
      for (Entry<String, SortedSet<FibRow>> entry2 : entry.getValue().entrySet()) {
        SortedSet<FibRow> fibs = entry2.getValue();
        for (FibRow fib : fibs) {
          Rule r = createFibRule(router, fib);
          rules.add(r);
        }
      }
    }

    // add the ACL rules
    for (AclGraphNode aclNode : _aclMap.values()) {
      List<GraphLink> links = _adjacencyLists.get(aclNode.getIndex());
      GraphLink drop = links.get(0);
      GraphLink accept = links.get(1);
      List<IpAccessListLine> lines = aclNode.getAcl().getLines();
      int i = lines.size();
      for (IpAccessListLine aclLine : aclNode.getAcl().getLines()) {
        Rule r = createAclRule(aclLine, drop, accept, i);
        rules.add(r);
        i--;
      }
      // default drop rule
      Rule r = createAclRule(null, drop, accept, 0);
      rules.add(r);
    }

    // Deterministically shuffle the input to get a better balanced KD tree
    Random rand = new Random(7);
    Collections.shuffle(rules, rand);
    for (Rule rule : rules) {
      addRule(rule);
    }

    System.out.println("Time to build labelled graph: " + (System.currentTimeMillis() - t));
    System.out.println("Number of classes: " + (_ecs.size()));
  }

  /*
   * Create a Rule from a FIB entry. The link corresponds to the
   * FIB next hop, and the priority is just the prefix length.
   */
  private Rule createFibRule(String router, FibRow fib) {
    NodeInterfacePair nip = new NodeInterfacePair(router, fib.getInterface());
    GraphLink link = _linkMap.get(nip);
    Prefix p = fib.getPrefix();
    long start = p.getStartIp().asLong();
    long end = p.getEndIp().asLong() + 1;
    HyperRectangle hr = GeometricSpace.fullSpace();
    hr.getBounds()[0] = start;
    hr.getBounds()[1] = end;
    return new Rule(link, hr, fib.getPrefix().getPrefixLength());
  }

  /*
   * Create a rule from an ACL line. The link is either to the drop
   * node or to the neighbor. The priority the inverse of the line number
   */
  private Rule createAclRule(
      @Nullable IpAccessListLine aclLine, GraphLink drop, GraphLink accept, int priority) {
    if (aclLine == null) {
      HyperRectangle rect = GeometricSpace.fullSpace();
      return new Rule(drop, rect, priority);
    } else {
      GeometricSpace space = GeometricSpace.fromAcl(aclLine);
      GraphLink link = (aclLine.getAction() == LineAction.ACCEPT ? accept : drop);
      return new Rule(link, space.rectangles().get(0), priority);
    }
  }

  /*
   * Ensure that we make ACL names unique to avoid conflicts
   * when mapping from the concrete name to the ACL's node.
   */
  private String getAclName(String router, String ifaceName, IpAccessList acl, boolean in) {
    return "ACL-" + "-" + (in ? "IN-" : "OUT-") + router + ifaceName + "-" + acl.getName();
  }

  /*
   * Initialize the edge-labelled graph by creating nodes for
   * every router, and special ACL nodes for every ACL.
   */
  private void initGraph(Batfish batfish, DataPlane dp) {
    _nodeMap = new HashMap<>();
    _aclMap = new HashMap<>();
    _linkMap = new HashMap<>();
    _allNodes = new ArrayList<>();
    _allLinks = new ArrayList<>();

    Map<String, Configuration> configs = batfish.loadConfigurations();

    // Create the nodes
    GraphNode dropNode = new GraphNode("(none)", 0);
    _nodeMap.put("(none)", dropNode);
    _allNodes.add(dropNode);

    int nodeIndex = 1;
    for (Entry<String, Configuration> entry : configs.entrySet()) {
      String router = entry.getKey();
      Configuration config = entry.getValue();
      GraphNode node = new GraphNode(router, nodeIndex);
      nodeIndex++;
      _nodeMap.put(router, node);
      _allNodes.add(node);
      // Create ACL nodes
      for (Entry<String, Interface> e : config.getInterfaces().entrySet()) {
        String ifaceName = e.getKey();
        Interface iface = e.getValue();
        IpAccessList outAcl = iface.getOutgoingFilter();
        if (outAcl != null) {
          String aclName = getAclName(router, ifaceName, outAcl, false);
          AclGraphNode aclNode = new AclGraphNode(aclName, nodeIndex, outAcl);
          nodeIndex++;
          _aclMap.put(aclName, aclNode);
          _allNodes.add(aclNode);
        }
        IpAccessList inAcl = iface.getIncomingFilter();
        if (inAcl != null) {
          String aclName = getAclName(router, ifaceName, inAcl, true);
          AclGraphNode aclNode = new AclGraphNode(aclName, nodeIndex, inAcl);
          nodeIndex++;
          _aclMap.put(aclName, aclNode);
          _allNodes.add(aclNode);
        }
      }
    }

    // Initialize the node adjacencies
    _adjacencyLists = new ArrayList<>(_allNodes.size());
    for (int i = 0; i < _allNodes.size(); i++) {
      _adjacencyLists.add(null);
    }
    for (GraphNode node : _nodeMap.values()) {
      _adjacencyLists.set(node.getIndex(), new ArrayList<>());
    }
    for (GraphNode node : _aclMap.values()) {
      _adjacencyLists.set(node.getIndex(), new ArrayList<>());
    }

    Map<NodeInterfacePair, NodeInterfacePair> edgeMap = new HashMap<>();
    for (Edge edge : dp.getTopologyEdges()) {
      edgeMap.put(edge.getInterface1(), edge.getInterface2());
    }

    // add edges that don't have a neighbor on the other side
    NodeInterfacePair nullPair = new NodeInterfacePair("(none)", "null_interface");
    for (Entry<String, Configuration> entry : configs.entrySet()) {
      String router = entry.getKey();
      Configuration config = entry.getValue();
      for (Entry<String, Interface> e : config.getInterfaces().entrySet()) {
        NodeInterfacePair nip = new NodeInterfacePair(router, e.getKey());
        if (!edgeMap.containsKey(nip)) {
          edgeMap.put(nip, nullPair);
        }
      }
    }

    int linkIndex = 0;

    // Create the edges
    for (GraphNode aclNode : _aclMap.values()) {
      GraphLink nullLink =
          new GraphLink(aclNode, "null_interface", dropNode, "null_interface", linkIndex);
      linkIndex++;
      _adjacencyLists.get(aclNode.getIndex()).add(nullLink);
      _allLinks.add(nullLink);
    }
    for (Entry<NodeInterfacePair, NodeInterfacePair> entry : edgeMap.entrySet()) {
      NodeInterfacePair nip1 = entry.getKey();
      NodeInterfacePair nip2 = entry.getValue();

      // Add a special null edge
      GraphNode src = _nodeMap.get(nip1.getHostname());
      GraphLink nullLink =
          new GraphLink(src, "null_interface", dropNode, "null_interface", linkIndex);
      linkIndex++;
      _linkMap.put(new NodeInterfacePair(nip1.getHostname(), "null_interface"), nullLink);
      _allLinks.add(nullLink);

      String router1 = nip1.getHostname();
      String router2 = nip2.getHostname();
      Configuration config1 = configs.get(router1);
      Configuration config2 = configs.get(router2);
      String ifaceName1 = nip1.getInterface();
      String ifaceName2 = nip2.getInterface();
      Interface iface1 = config1.getInterfaces().get(ifaceName1);
      Interface iface2 = config2 == null ? null : config2.getInterfaces().get(ifaceName2);
      IpAccessList outAcl = iface1.getOutgoingFilter();
      IpAccessList inAcl = iface2 == null ? null : iface2.getIncomingFilter();

      if (outAcl != null) {
        // add a link to the ACL
        String outAclName = getAclName(router1, ifaceName1, outAcl, false);
        GraphNode tgt1 = _aclMap.get(outAclName);
        GraphLink l1 = new GraphLink(src, ifaceName1, tgt1, "enter-outbound-acl", linkIndex);
        linkIndex++;
        _linkMap.put(nip1, l1);
        _adjacencyLists.get(src.getIndex()).add(l1);
        _allLinks.add(l1);
        // if inbound acl, then add that
        if (inAcl != null) {
          String inAclName = getAclName(router2, ifaceName2, inAcl, true);
          GraphNode tgt2 = _aclMap.get(inAclName);
          GraphLink l2 =
              new GraphLink(tgt1, "exit-outbound-acl", tgt2, "enter-inbound-acl", linkIndex);
          linkIndex++;
          _adjacencyLists.get(tgt1.getIndex()).add(l2);
          _allLinks.add(l2);
          // add a link from ACL to peer
          GraphNode tgt3 = _nodeMap.get(router2);
          GraphLink l3 = new GraphLink(tgt2, "exit-inbound-acl", tgt3, ifaceName2, linkIndex);
          linkIndex++;
          _adjacencyLists.get(tgt2.getIndex()).add(l3);
          _allLinks.add(l3);
        } else {
          // add a link from ACL to peer
          GraphNode tgt2 = _nodeMap.get(router2);
          GraphLink l2 = new GraphLink(tgt1, "exit-outbound-acl", tgt2, ifaceName2, linkIndex);
          linkIndex++;
          _adjacencyLists.get(tgt1.getIndex()).add(l2);
          _allLinks.add(l2);
        }
      } else {
        if (inAcl != null) {
          String inAclName = getAclName(router2, ifaceName2, inAcl, true);
          GraphNode tgt1 = _aclMap.get(inAclName);
          GraphLink l1 = new GraphLink(src, ifaceName1, tgt1, "enter-inbound-acl", linkIndex);
          linkIndex++;
          _linkMap.put(nip1, l1);
          _adjacencyLists.get(src.getIndex()).add(l1);
          _allLinks.add(l1);
          // add a link from ACL to peer
          GraphNode tgt2 = _nodeMap.get(router2);
          GraphLink l2 = new GraphLink(tgt1, "exit-inbound-acl", tgt2, ifaceName2, linkIndex);
          linkIndex++;
          _adjacencyLists.get(tgt1.getIndex()).add(l2);
          _allLinks.add(l2);
        } else {
          GraphNode tgt = _nodeMap.get(router2);
          GraphLink l = new GraphLink(src, ifaceName1, tgt, ifaceName2, linkIndex);
          linkIndex++;
          _linkMap.put(nip1, l);
          _adjacencyLists.get(src.getIndex()).add(l);
          _allLinks.add(l);
        }
      }
    }
  }

  /* private void showStatus() {
    System.out.println("=====================");
    for (int i = 0; i < _ecs.size(); i++) {
      HyperRectangle r = _ecs.get(i);
      System.out.println(i + " --> " + r);
    }
    System.out.println("=====================");
  } */

  /*
   * Does a deep copy of the map from one equivalence class to another.
   * This is slow and memory intensive, and could be replaced later if a bottleneck.
   */
  private Map<GraphNode, PriorityQueue<Rule>> copyMap(Map<GraphNode, PriorityQueue<Rule>> map) {
    Map<GraphNode, PriorityQueue<Rule>> newMap = new HashMap<>(map.size());
    for (Entry<GraphNode, PriorityQueue<Rule>> entry : map.entrySet()) {
      newMap.put(entry.getKey(), new PriorityQueue<>(entry.getValue()));
    }
    return newMap;
  }

  /*
   * Add a rule to the edge-labelled graph by first refining
   * the equivalence classes, finding the relevant overlap,
   * and updating the edge labels accordingly.
   */
  private void addRule(Rule r) {
    HyperRectangle hr = r.getRectangle();

    // showStatus();
    List<HyperRectangle> overlapping = new ArrayList<>();
    List<Tuple<HyperRectangle, HyperRectangle>> delta = new ArrayList<>();
    for (HyperRectangle other : _kdtree.intersect(hr)) {
      HyperRectangle overlap = hr.overlap(other);
      assert (overlap != null);
      Collection<HyperRectangle> newRects = other.divide(overlap);
      if (newRects == null) {
        overlapping.add(other);
      } else {
        _kdtree.delete(other);
        boolean first = true;
        for (HyperRectangle rect : newRects) {
          if (first && !rect.equals(other)) {
            other.setBounds(rect.getBounds());
            first = false;
            rect = other;
          } else {
            rect.setAlphaIndex(_ecs.size());
            _ecs.add(rect);
            _ownerMap.add(null);
            delta.add(new Tuple<>(other, rect));
          }
          _kdtree.insert(rect);
          if (rect.equals(overlap)) {
            overlapping.add(rect);
          }
        }
      }
    }

    // create new rectangles
    for (Tuple<HyperRectangle, HyperRectangle> d : delta) {
      HyperRectangle alpha = d.getFirst();
      HyperRectangle alphaPrime = d.getSecond();
      Map<GraphNode, PriorityQueue<Rule>> existing = _ownerMap.get(alpha.getAlphaIndex());
      _ownerMap.set(alphaPrime.getAlphaIndex(), copyMap(existing));
      for (Entry<GraphNode, PriorityQueue<Rule>> entry : existing.entrySet()) {
        PriorityQueue<Rule> pq = entry.getValue();
        if (!pq.isEmpty()) {
          Rule highestPriority = pq.peek();
          GraphLink link = highestPriority.getLink();
          _labels[link.getIndex()].set(alphaPrime.getAlphaIndex());
        }
      }
    }

    // Update data structures
    for (HyperRectangle alpha : overlapping) {
      Rule rPrime = null;
      PriorityQueue<Rule> pq = _ownerMap.get(alpha.getAlphaIndex()).get(r.getLink().getSource());
      if (!pq.isEmpty()) {
        rPrime = pq.peek();
      }
      if (rPrime == null || rPrime.compareTo(r) < 0) {
        _labels[r.getLink().getIndex()].set(alpha.getAlphaIndex());
        if (rPrime != null && !(Objects.equal(r.getLink(), rPrime.getLink()))) {
          _labels[rPrime.getLink().getIndex()].set(alpha.getAlphaIndex(), false);
        }
      }
      pq.add(r);
    }
  }

  private BitSet actionFlags(Set<ForwardingAction> actions) {
    BitSet actionFlags = new BitSet();

    boolean accept = actions.contains(ForwardingAction.ACCEPT);
    boolean drop = actions.contains(ForwardingAction.DROP);
    boolean dropAclIn = actions.contains(ForwardingAction.DROP_ACL_IN);
    boolean dropAclOut = actions.contains(ForwardingAction.DROP_ACL_OUT);
    boolean dropAcl = actions.contains(ForwardingAction.DROP_ACL);
    boolean dropNullRoute = actions.contains(ForwardingAction.DROP_NULL_ROUTE);
    boolean dropNoRoute = actions.contains(ForwardingAction.DROP_NO_ROUTE);

    if (accept) {
      actionFlags.set(ACCEPT_FLAG);
    }
    if (drop) {
      actionFlags.set(DROP_FLAG);
    }
    if (dropAcl) {
      actionFlags.set(DROP_ACL_FLAG);
    }
    if (dropAclIn) {
      actionFlags.set(DROP_ACL_IN_FLAG);
    }
    if (dropAclOut) {
      actionFlags.set(DROP_ACL_OUT_FLAG);
    }
    if (dropNullRoute) {
      actionFlags.set(DROP_NULL_ROUTE_FLAG);
    }
    if (dropNoRoute) {
      actionFlags.set(DROP_NO_ROUTE_FLAG);
    }

    return actionFlags;
  }

  /*
   * Return an example of a flow satisfying the user's query.
   * This will be the standard FlowHistory object for reachability.
   * Finds all relevant equivalence classes and checks reachability on
   * them each in turn.
   */
  public AnswerElement reachable(
      HeaderSpace h, Set<ForwardingAction> actions, Set<String> src, Set<String> dst) {

    long l = System.currentTimeMillis();

    Set<GraphNode> sources = new HashSet<>();
    Set<GraphNode> sinks = new HashSet<>();
    for (String s : src) {
      sources.add(_nodeMap.get(s));
    }
    for (String d : dst) {
      sinks.add(_nodeMap.get(d));
    }

    BitSet flags = actionFlags(actions);

    // Pick out the relevant equivalence classes
    GeometricSpace space = GeometricSpace.fromHeaderSpace(h);
    Map<HyperRectangle, HyperRectangle> canonicalChoices = new HashMap<>();
    for (HyperRectangle rect : space.rectangles()) {
      List<HyperRectangle> relevant = _kdtree.intersect(rect);
      for (HyperRectangle r : relevant) {
        HyperRectangle overlap = rect.overlap(r);
        canonicalChoices.put(r, overlap);
      }
    }

    // Check each equivalence class for reachability
    for (Entry<HyperRectangle, HyperRectangle> entry : canonicalChoices.entrySet()) {
      HyperRectangle equivClass = entry.getKey();
      HyperRectangle overlap = entry.getValue();
      Tuple<Path, FlowDisposition> tup =
          reachable(equivClass.getAlphaIndex(), flags, sources, sinks);
      if (tup != null) {
        System.out.println("Reachability time: " + (System.currentTimeMillis() - l));
        return createReachabilityAnswer(GeometricSpace.example(overlap), tup);
      }
    }
    System.out.println("Reachability time: " + (System.currentTimeMillis() - l));
    return new FlowHistory();
  }

  /*
   * Create a reachability answer element for compatibility
   * with the standard Batfish reachability question.
   */
  private AnswerElement createReachabilityAnswer(HeaderSpace h, Tuple<Path, FlowDisposition> tup) {
    FlowHistory fh = new FlowHistory();

    TcpFlags flags = h.getTcpFlags().get(0);
    int tcpCwr = flags.getCwr() ? 1 : 0;
    int tcpEce = flags.getEce() ? 1 : 0;
    int tcpUrg = flags.getUrg() ? 1 : 0;
    int tcpAck = flags.getAck() ? 1 : 0;
    int tcpPsh = flags.getPsh() ? 1 : 0;
    int tcpRst = flags.getRst() ? 1 : 0;
    int tcpSyn = flags.getSyn() ? 1 : 0;
    int tcpFin = flags.getFin() ? 1 : 0;

    Flow.Builder b = new Flow.Builder();
    b.setIngressNode(tup.getFirst().getSource().getName());
    b.setSrcIp(h.getSrcIps().first().getIp());
    b.setDstIp(h.getDstIps().first().getIp());
    b.setSrcPort(h.getSrcPorts().first().getStart());
    b.setDstPort(h.getDstPorts().first().getStart());
    b.setIpProtocol(h.getIpProtocols().first());
    b.setIcmpType(h.getIcmpTypes().first().getStart());
    b.setIcmpCode(h.getIcmpCodes().first().getStart());
    b.setTcpFlagsCwr(tcpCwr);
    b.setTcpFlagsEce(tcpEce);
    b.setTcpFlagsUrg(tcpUrg);
    b.setTcpFlagsAck(tcpAck);
    b.setTcpFlagsPsh(tcpPsh);
    b.setTcpFlagsRst(tcpRst);
    b.setTcpFlagsSyn(tcpSyn);
    b.setTcpFlagsFin(tcpFin);
    b.setTag("DELTANET");

    Flow flow = b.build();

    String testRigName = _batfish.getTestrigName();
    Environment environment =
        new Environment(
            "BASE", testRigName, new TreeSet<>(), null, null, null, null, new TreeSet<>());

    String note = "";
    Path path = tup.getFirst();
    FlowDisposition fd = tup.getSecond();
    if (fd == FlowDisposition.NO_ROUTE) {
      note = "NO_ROUTE";
    }
    if (fd == FlowDisposition.NULL_ROUTED) {
      note = "NULL_ROUTED";
    }
    if (fd == FlowDisposition.ACCEPTED) {
      note = "ACCEPTED";
    }
    if (fd == FlowDisposition.DENIED_OUT || fd == FlowDisposition.DENIED_IN) {
      AclGraphNode aclNode = (AclGraphNode) path.getDestination();
      IpAccessList acl = aclNode.getAcl();
      FilterResult fr = acl.filter(flow);
      String line = "default deny";
      if (fr.getMatchLine() != null) {
        line = acl.getLines().get(fr.getMatchLine()).getName();
      }
      String type = (fd == FlowDisposition.DENIED_OUT) ? "OUT" : "IN";
      note = String.format("DENIED_%s{%s}{%s}", type, acl.getName(), line);
    }

    List<FlowTraceHop> hops = new ArrayList<>();
    for (GraphLink link : path) {
      GraphNode src = link.getSource();
      GraphNode tgt = link.getTarget();
      Edge edge =
          new Edge(src.getName(), link.getSourceIface(), tgt.getName(), link.getTargetIface());
      FlowTraceHop hop = new FlowTraceHop(edge, new TreeSet<>(), null);
      hops.add(hop);
    }

    FlowTrace flowTrace = new FlowTrace(fd, hops, note);
    fh.addFlowTrace(flow, "BASE", environment, flowTrace);
    return fh;
  }

  /*
   * From a BFS search, reconstruct the actual path used to
   * get to the destination node.
   */
  private Path reconstructPath(GraphLink[] predecessors, GraphNode dst) {
    List<GraphLink> list = new ArrayList<>();
    GraphNode current = dst;
    GraphLink prev = predecessors[dst.getIndex()];
    while (prev != null) {
      list.add(prev);
      current = prev.getSource();
      prev = predecessors[current.getIndex()];
    }
    return new Path(list, current, dst);
  }

  /*
   * Check reachability for an individual equivalence class.
   * Depending on the action requested from the query, it will
   * stop the search when it has found a relevant path and return it.
   */
  @Nullable
  private Tuple<Path, FlowDisposition> reachable(
      int alphaIdx, BitSet flags, Set<GraphNode> sources, Set<GraphNode> sinks) {
    Queue<GraphNode> todo = new ArrayDeque<>();

    GraphLink[] predecessors = new GraphLink[_allNodes.size()];
    BitSet visited = new BitSet(_allNodes.size());
    todo.addAll(sources);
    for (GraphNode source : sources) {
      predecessors[source.getIndex()] = null;
    }

    while (!todo.isEmpty()) {
      GraphNode current = todo.remove();
      // packet accepted at a destination
      if (sinks.contains(current) && flags.get(ACCEPT_FLAG)) {
        // TODO: handle difference between accepted and NEIGHBOR_UNREACHABLE_OR_EXITS_NETWORK
        return new Tuple<>(reconstructPath(predecessors, current), FlowDisposition.ACCEPTED);
      }

      visited.set(current.getIndex());
      int numLinks = 0;
      for (GraphLink link : _adjacencyLists.get(current.getIndex())) {
        if (_labels[link.getIndex()].get(alphaIdx)) {
          numLinks++;
          GraphNode neighbor = link.getTarget();
          // packet is dropped, figure out what went wrong
          if (neighbor.isDropNode()) {
            String name = current.getName();
            if ((flags.get(DROP_ACL_IN_FLAG) || flags.get(DROP_ACL_FLAG))
                && name.startsWith("ACL-IN")) {
              return new Tuple<>(reconstructPath(predecessors, current), FlowDisposition.DENIED_IN);
            }
            if ((flags.get(DROP_ACL_OUT_FLAG) || flags.get(DROP_ACL_FLAG))
                && name.startsWith("ACL-OUT")) {
              return new Tuple<>(
                  reconstructPath(predecessors, current), FlowDisposition.DENIED_OUT);
            }
            if (flags.get(DROP_NULL_ROUTE_FLAG) && link.getSourceIface().equals("null_interface")) {
              return new Tuple<>(
                  reconstructPath(predecessors, current), FlowDisposition.NULL_ROUTED);
            }
          }
          if (!visited.get(neighbor.getIndex())) {
            todo.add(neighbor);
            predecessors[neighbor.getIndex()] = link;
          }
        }
      }
      // the router doesn't know how to forward the packet
      if (flags.get(DROP_NO_ROUTE_FLAG) && numLinks == 0) {
        return new Tuple<>(reconstructPath(predecessors, current), FlowDisposition.NO_ROUTE);
      }
      if (flags.get(DROP_FLAG) && numLinks == 0) {
        return new Tuple<>(reconstructPath(predecessors, current), FlowDisposition.NO_ROUTE);
      }
    }
    return null;
  }
}
