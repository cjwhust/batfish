package org.batfish.datamodel;

import static com.google.common.base.MoreObjects.firstNonNull;
import static com.google.common.base.Preconditions.checkArgument;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.benmanes.caffeine.cache.LoadingCache;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.ImmutableSortedSet;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.SortedSet;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;
import javax.annotation.ParametersAreNonnullByDefault;
import org.batfish.datamodel.BgpRoute.Builder;
import org.batfish.datamodel.bgp.community.Community;
import org.batfish.datamodel.bgp.community.ExtendedCommunity;
import org.batfish.datamodel.bgp.community.StandardCommunity;
import org.batfish.datamodel.route.nh.NextHop;
import org.batfish.datamodel.routing_policy.communities.CommunitySet;

/** A generic BGP route containing the common properties among different types of BGP routes */
@ParametersAreNonnullByDefault
public abstract class BgpRoute<B extends Builder<B, R>, R extends BgpRoute<B, R>>
    extends AbstractRoute
    implements HasReadableAsPath,
        HasReadableCommunities,
        HasReadableLocalPreference,
        HasReadableOriginType,
        HasReadableSourceProtocol,
        HasReadableWeight {

  /** Local-preference has a maximum value of u32 max. */
  public static final long MAX_LOCAL_PREFERENCE = (1L << 32) - 1;

  // Soft values: let it be garbage collected in times of pressure.
  // Maximum size 2^16: Just some upper bound on cache size, well less than GiB.
  //   (8 bytes seems smallest possible entry (set(long)), would be 1 MiB total).
  private static final LoadingCache<Set<Long>, Set<Long>> CLUSTER_CACHE =
      Caffeine.newBuilder().softValues().maximumSize(1 << 16).build(ImmutableSet::copyOf);

  /** Builder for {@link BgpRoute} */
  @ParametersAreNonnullByDefault
  public abstract static class Builder<B extends Builder<B, R>, R extends BgpRoute<B, R>>
      extends AbstractRouteBuilder<B, R>
      implements HasWritableAsPath<B, R>,
          HasWritableCommunities<B, R>,
          HasWritableLocalPreference<B, R>,
          HasWritableOriginType<B, R>,
          HasWritableWeight<B, R> {

    @Nonnull protected AsPath _asPath;
    // Invariant: either immutable or a local copy shielded from external mutations.
    @Nonnull protected Set<Long> _clusterList;
    @Nonnull protected CommunitySet _communities;
    protected long _localPreference;
    @Nullable protected Ip _originatorIp;
    @Nullable protected OriginMechanism _originMechanism;
    @Nullable protected OriginType _originType;
    @Nullable protected RoutingProtocol _protocol;
    @Nullable protected Ip _receivedFromIp;
    protected boolean _receivedFromRouteReflectorClient;
    @Nullable protected RoutingProtocol _srcProtocol;
    protected int _weight;

    protected Builder() {
      _asPath = AsPath.empty();
      _communities = CommunitySet.empty();
      _clusterList = ImmutableSet.of();
    }

    /**
     * Returns a completely new builder of type {@link B} which has all the fields unset.
     *
     * @return A completely new builder of type {@link B}.
     */
    /* This is needed in cases where we need to create a new builder having type same as any of the
    subclasses of BgpRoute's builder but we are not sure of the exact type of the concrete child
    class.
    For example while evaluating a routing policy and executing its statements we need
    to create a completely new builder which should be of the same type as environment's output
    route builder but we are not sure of the concrete type and only know that it extends the
    abstract BgpRoute's builder. */
    @Nonnull
    public abstract B newBuilder();

    @Nonnull
    @Override
    public abstract R build();

    @Nonnull
    @Override
    public AsPath getAsPath() {
      return _asPath;
    }

    @Nonnull
    public Set<Long> getClusterList() {
      return _clusterList instanceof ImmutableSet
          ? _clusterList
          : Collections.unmodifiableSet(_clusterList);
    }

    @Nonnull
    @Override
    public CommunitySet getCommunities() {
      return _communities;
    }

    @Nonnull
    @Override
    public Set<Community> getCommunitiesAsSet() {
      return _communities.getCommunities();
    }

    @Override
    public long getLocalPreference() {
      return _localPreference;
    }

    @Nullable
    public Ip getOriginatorIp() {
      return _originatorIp;
    }

    public @Nullable OriginMechanism getOriginMechanism() {
      return _originMechanism;
    }

    @Nullable
    @Override
    public OriginType getOriginType() {
      return _originType;
    }

    @Nullable
    public RoutingProtocol getProtocol() {
      return _protocol;
    }

    @Override
    @Nonnull
    protected abstract B getThis();

    @Override
    public int getWeight() {
      return _weight;
    }

    @Nonnull
    @Override
    public B setAsPath(AsPath asPath) {
      _asPath = asPath;
      return getThis();
    }

    /** Overwrite the clusterList attribute */
    public B setClusterList(Set<Long> clusterList) {
      _clusterList = clusterList instanceof ImmutableSet ? clusterList : new HashSet<>(clusterList);
      return getThis();
    }

    /** Add to the cluster list attribute */
    public B addClusterList(Set<Long> clusterList) {
      if (_clusterList instanceof ImmutableSet) {
        _clusterList = new HashSet<>(_clusterList);
      }
      _clusterList.addAll(clusterList);
      return getThis();
    }

    /** Add to the cluster list attribute */
    public B addToClusterList(Long cluster) {
      if (_clusterList instanceof ImmutableSet) {
        _clusterList = new HashSet<>(_clusterList);
      }
      _clusterList.add(cluster);
      return getThis();
    }

    /** Overwrite communities */
    @Nonnull
    @Override
    public B setCommunities(CommunitySet communities) {
      _communities = communities;
      return getThis();
    }

    /** Overwrite communities */
    // TODO: remove in favor of setCommunities(CommunitySet)
    public B setCommunities(Collection<? extends Community> communities) {
      _communities = CommunitySet.of(communities);
      return getThis();
    }

    /** Add communities */
    public B addCommunities(Collection<? extends Community> communities) {
      if (communities.isEmpty()) {
        return getThis();
      }
      Set<Community> currentCommunities = _communities.getCommunities();
      if (currentCommunities.isEmpty()) {
        return setCommunities(communities);
      }
      if (currentCommunities.containsAll(communities)) {
        return getThis();
      }
      Set<Community> combined =
          ImmutableSet.<Community>builderWithExpectedSize(
                  currentCommunities.size() + communities.size())
              .addAll(currentCommunities)
              .addAll(communities)
              .build();
      _communities = CommunitySet.of(combined);
      return getThis();
    }

    @Nonnull
    @Override
    public B setLocalPreference(long localPreference) {
      _localPreference = localPreference;
      return getThis();
    }

    public B setOriginatorIp(Ip originatorIp) {
      _originatorIp = originatorIp;
      return getThis();
    }

    @Nonnull
    public B setOriginMechanism(OriginMechanism originMechanism) {
      _originMechanism = originMechanism;
      return getThis();
    }

    @Nonnull
    @Override
    public B setOriginType(OriginType originType) {
      _originType = originType;
      return getThis();
    }

    public B setProtocol(RoutingProtocol protocol) {
      _protocol = protocol;
      return getThis();
    }

    public B setReceivedFromIp(@Nullable Ip receivedFromIp) {
      _receivedFromIp = receivedFromIp;
      return getThis();
    }

    public B setReceivedFromRouteReflectorClient(boolean receivedFromRouteReflectorClient) {
      _receivedFromRouteReflectorClient = receivedFromRouteReflectorClient;
      return getThis();
    }

    public B setSrcProtocol(@Nullable RoutingProtocol srcProtocol) {
      _srcProtocol = srcProtocol;
      return getThis();
    }

    @Nonnull
    @Override
    public B setWeight(int weight) {
      _weight = weight;
      return getThis();
    }
  }

  /** Default local preference for a BGP route if one is not set explicitly */
  public static final long DEFAULT_LOCAL_PREFERENCE = 100L;

  /** Default weight for a local BGP route. */
  public static final int DEFAULT_LOCAL_WEIGHT = 32768;

  public static final String PROP_AS_PATH = "asPath";
  static final String PROP_CLUSTER_LIST = "clusterList";
  public static final String PROP_COMMUNITIES = "communities";
  public static final String PROP_LOCAL_PREFERENCE = "localPreference";
  static final String PROP_ORIGIN_MECHANISM = "originMechanism";
  static final String PROP_ORIGIN_TYPE = "originType";
  static final String PROP_ORIGINATOR_IP = "originatorIp";
  static final String PROP_RECEIVED_FROM_IP = "receivedFromIp";
  static final String PROP_RECEIVED_FROM_ROUTE_REFLECTOR_CLIENT =
      "receivedFromRouteReflectorClient";
  static final String PROP_SRC_PROTOCOL = "srcProtocol";
  static final String PROP_WEIGHT = "weight";

  @Nonnull protected final AsPath _asPath;
  @Nonnull protected final Set<Long> _clusterList;
  @Nonnull protected final CommunitySet _communities;
  protected final long _localPreference;
  protected final long _med;
  @Nonnull protected final Ip _originatorIp;
  @Nonnull protected final OriginMechanism _originMechanism;
  @Nonnull protected final OriginType _originType;
  @Nonnull protected final RoutingProtocol _protocol;

  /**
   * The {@link Ip} address of the (I)BGP peer from which the route was learned, or {@link Ip#ZERO}
   * if the BGP route was originated locally.
   *
   * <p>Set on origination and on import.
   */
  @Nullable protected final Ip _receivedFromIp;

  protected final boolean _receivedFromRouteReflectorClient;
  @Nullable protected final RoutingProtocol _srcProtocol;
  /* NOTE: Cisco-only attribute */
  protected final int _weight;

  protected BgpRoute(
      @Nullable Prefix network,
      @Nonnull NextHop nextHop,
      int admin,
      @Nullable AsPath asPath,
      @Nonnull CommunitySet communities,
      long localPreference,
      long med,
      Ip originatorIp,
      @Nullable Set<Long> clusterList,
      boolean receivedFromRouteReflectorClient,
      OriginMechanism originMechanism,
      OriginType originType,
      RoutingProtocol protocol,
      @Nullable Ip receivedFromIp,
      @Nullable RoutingProtocol srcProtocol,
      long tag,
      int weight,
      boolean nonForwarding,
      boolean nonRouting) {
    super(network, admin, tag, nonRouting, nonForwarding);
    checkArgument(
        protocol == RoutingProtocol.BGP
            || protocol == RoutingProtocol.IBGP
            || protocol == RoutingProtocol.AGGREGATE,
        "Invalid BgpRoute protocol");
    _asPath = firstNonNull(asPath, AsPath.empty());
    _clusterList = clusterList == null ? ImmutableSet.of() : CLUSTER_CACHE.get(clusterList);
    _communities = communities;
    _localPreference = localPreference;
    _med = med;
    _nextHop = nextHop;
    _originatorIp = originatorIp;
    _originMechanism = originMechanism;
    _originType = originType;
    _protocol = protocol;
    _receivedFromIp = receivedFromIp;
    _receivedFromRouteReflectorClient = receivedFromRouteReflectorClient;
    _srcProtocol = srcProtocol;
    _weight = weight;
  }

  @Nonnull
  @JsonProperty(PROP_AS_PATH)
  @Override
  public AsPath getAsPath() {
    return _asPath;
  }

  public @Nonnull Set<Long> getClusterList() {
    return _clusterList;
  }

  /** Return the set of all community attributes */
  @Nonnull
  @Override
  public final CommunitySet getCommunities() {
    return _communities;
  }

  /** Return the set of all community attributes */
  @Nonnull
  @Override
  public final Set<Community> getCommunitiesAsSet() {
    return _communities.getCommunities();
  }

  /** Return only standard community attributes */
  @Nonnull
  @JsonIgnore
  public Set<StandardCommunity> getStandardCommunities() {
    return _communities.getStandardCommunities();
  }

  /** Return only extended community attributes */
  @Nonnull
  @JsonIgnore
  public Set<ExtendedCommunity> getExtendedCommunities() {
    return _communities.getExtendedCommunities();
  }

  @JsonProperty(PROP_LOCAL_PREFERENCE)
  @Override
  public long getLocalPreference() {
    return _localPreference;
  }

  @JsonIgnore(false)
  @JsonProperty(PROP_METRIC)
  @Override
  public long getMetric() {
    return _med;
  }

  @Nonnull
  @JsonProperty(PROP_ORIGINATOR_IP)
  public Ip getOriginatorIp() {
    return _originatorIp;
  }

  @Nonnull
  @JsonProperty(PROP_ORIGIN_MECHANISM)
  public OriginMechanism getOriginMechanism() {
    return _originMechanism;
  }

  @Nonnull
  @JsonProperty(PROP_ORIGIN_TYPE)
  @Override
  public OriginType getOriginType() {
    return _originType;
  }

  @Nonnull
  @JsonIgnore(false)
  @JsonProperty(PROP_PROTOCOL)
  @Override
  public RoutingProtocol getProtocol() {
    return _protocol;
  }

  @Nullable
  @JsonProperty(PROP_RECEIVED_FROM_IP)
  public Ip getReceivedFromIp() {
    return _receivedFromIp;
  }

  @JsonProperty(PROP_RECEIVED_FROM_ROUTE_REFLECTOR_CLIENT)
  public boolean getReceivedFromRouteReflectorClient() {
    return _receivedFromRouteReflectorClient;
  }

  @JsonProperty(PROP_SRC_PROTOCOL)
  @Override
  public @Nullable RoutingProtocol getSrcProtocol() {
    return _srcProtocol;
  }

  @JsonProperty(PROP_WEIGHT)
  @Override
  public int getWeight() {
    return _weight;
  }

  @Override
  public abstract B toBuilder();

  @JsonProperty(PROP_CLUSTER_LIST)
  private @Nonnull SortedSet<Long> getJsonClusterList() {
    return ImmutableSortedSet.copyOf(_clusterList);
  }

  @JsonProperty(PROP_COMMUNITIES)
  private @Nonnull CommunitySet getJsonCommunities() {
    return _communities;
  }

  /** Whether the route is a trackable redistributed local route. */
  @JsonIgnore
  public boolean isTrackableLocalRoute() {
    switch (_originMechanism) {
      case NETWORK:
      case REDISTRIBUTE:
        return true;
      case GENERATED:
      case LEARNED:
        return false;
      default:
        throw new IllegalArgumentException(
            String.format("Unhandled OriginMechanism: %s", _originMechanism));
    }
  }
}
