package org.batfish.datamodel.matchers;

import static org.hamcrest.Matchers.equalTo;

import java.util.Collection;
import javax.annotation.Nonnull;
import org.batfish.datamodel.BumTransportMethod;
import org.batfish.datamodel.Ip;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasBumTransportIps;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasBumTransportMethod;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasLearnedNexthopVtepIps;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasSourceAddress;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasUdpPort;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasVlan;
import org.batfish.datamodel.matchers.VniMatchersImpl.HasVni;
import org.batfish.datamodel.vxlan.Layer2Vni;
import org.batfish.datamodel.vxlan.Layer3Vni;
import org.batfish.datamodel.vxlan.Vni;
import org.hamcrest.Matcher;

public class VniMatchers {

  private VniMatchers() {}

  /**
   * Provides a matcher that matches if the {@link Layer2Vni}'s BUM transport IPs matches the {@code
   * subMatcher}.
   */
  public static @Nonnull Matcher<Layer2Vni> hasBumTransportIps(
      @Nonnull Matcher<? super Iterable<Ip>> subMatcher) {
    return new HasBumTransportIps(subMatcher);
  }

  /**
   * Provides a matcher that matches if the {@link Layer3Vni}'s learned next-hop VTEP IPs matches
   * the {@code subMatcher}.
   */
  public static @Nonnull Matcher<Layer3Vni> hasLearnedNexthopVtepIps(
      @Nonnull Matcher<? super Collection<Ip>> subMatcher) {
    return new HasLearnedNexthopVtepIps(subMatcher);
  }

  /**
   * Provides a matcher that matches if the {@link Vni}'s BUM transport method matches the {@code
   * subMatcher}.
   */
  public static @Nonnull Matcher<Layer2Vni> hasBumTransportMethod(
      @Nonnull Matcher<? super BumTransportMethod> subMatcher) {
    return new HasBumTransportMethod(subMatcher);
  }

  /**
   * Provides a matcher that matches if the {@link Vni}'s source IP address matches the {@code
   * subMatcher}.
   */
  public static @Nonnull Matcher<Vni> hasSourceAddress(@Nonnull Matcher<? super Ip> subMatcher) {
    return new HasSourceAddress(subMatcher);
  }

  /**
   * Provides a matcher that matches if the {@link Vni}'s UDP port matches the {@code subMatcher}.
   */
  public static @Nonnull Matcher<Vni> hasUdpPort(@Nonnull Matcher<? super Integer> subMatcher) {
    return new HasUdpPort(subMatcher);
  }

  /**
   * Provides a matcher that matches if the {@link Vni}'s VLAN number matches the {@code
   * subMatcher}.
   */
  public static @Nonnull Matcher<Layer2Vni> hasVlan(@Nonnull Matcher<? super Integer> subMatcher) {
    return new HasVlan(subMatcher);
  }

  /** Provides a matcher that matches if the {@link Vni}'s VLAN number matches the {@code vni}. */
  public static @Nonnull Matcher<Vni> hasVni(int vni) {
    return new HasVni(equalTo(vni));
  }
}
