package org.batfish.question.routes;

import static com.google.common.base.MoreObjects.firstNonNull;
import static java.util.Comparator.comparing;
import static java.util.Comparator.nullsLast;

import com.google.common.collect.ImmutableList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;
import javax.annotation.ParametersAreNullableByDefault;
import org.batfish.datamodel.AbstractRoute;
import org.batfish.datamodel.AsPath;
import org.batfish.datamodel.BgpRoute;
import org.batfish.datamodel.Ip;
import org.batfish.datamodel.OriginMechanism;
import org.batfish.datamodel.OriginType;
import org.batfish.datamodel.Route;
import org.batfish.datamodel.questions.BgpRouteStatus;

/**
 * Contains the non-key attributes of {@link BgpRoute}s and {@link AbstractRoute}s and defines a
 * sorting order for these attributes.
 */
@ParametersAreNullableByDefault
public class RouteRowAttribute implements Comparable<RouteRowAttribute> {
  @Nullable private final String _nextHopInterface;

  @Nullable private final AsPath _asPath;

  @Nullable private final Integer _adminDistance;

  @Nonnull private final List<String> _communities;

  @Nullable private final Long _localPreference;

  @Nullable private final Long _metric;

  @Nullable private final String _originProtocol;

  @Nullable private final OriginMechanism _originMechanism;

  @Nullable private final OriginType _originType;

  @Nullable private final Ip _receivedFromIp;

  @Nullable private final Long _tag;

  @Nullable private final BgpRouteStatus _status;

  @Nullable private final Integer _weight;

  private RouteRowAttribute(
      String nextHopInterface,
      Integer adminDistance,
      Long metric,
      AsPath asPath,
      Long localPreference,
      List<String> communities,
      String originalProtocol,
      OriginMechanism originMechanism,
      OriginType originType,
      Ip receivedFromIp,
      Long tag,
      BgpRouteStatus status,
      Integer weight) {
    _nextHopInterface = nextHopInterface;
    _adminDistance = adminDistance;
    _metric = metric;
    _asPath = asPath;
    _localPreference = localPreference;
    _communities = firstNonNull(communities, ImmutableList.of());
    _originProtocol = originalProtocol;
    _originMechanism = originMechanism;
    _originType = originType;
    _receivedFromIp = receivedFromIp;
    _tag = tag;
    _status = status;
    _weight = weight;
  }

  @Nullable
  public Integer getAdminDistance() {
    return _adminDistance;
  }

  @Nullable
  public Long getMetric() {
    return _metric;
  }

  @Nullable
  public AsPath getAsPath() {
    return _asPath;
  }

  @Nullable
  public Long getLocalPreference() {
    return _localPreference;
  }

  @Nonnull
  public List<String> getCommunities() {
    return _communities;
  }

  @Nullable
  public String getNextHopInterface() {
    return _nextHopInterface;
  }

  @Nullable
  public String getOriginProtocol() {
    return _originProtocol;
  }

  @Nullable
  public OriginMechanism getOriginMechanism() {
    return _originMechanism;
  }

  @Nullable
  public OriginType getOriginType() {
    return _originType;
  }

  public @Nullable Ip getReceivedFromIp() {
    return _receivedFromIp;
  }

  @Nullable
  public Long getTag() {
    return _tag;
  }

  @Nullable
  public BgpRouteStatus getStatus() {
    return _status;
  }

  @Nullable
  public Integer getWeight() {
    return _weight;
  }

  public static Builder builder() {
    return new Builder();
  }

  private static final Comparator<RouteRowAttribute> COMPARATOR =
      comparing(RouteRowAttribute::getNextHopInterface, nullsLast(String::compareTo))
          .thenComparing(RouteRowAttribute::getAdminDistance, nullsLast(Integer::compareTo))
          .thenComparing(RouteRowAttribute::getMetric, nullsLast(Long::compareTo))
          .thenComparing(RouteRowAttribute::getAsPath, nullsLast(AsPath::compareTo))
          .thenComparing(RouteRowAttribute::getLocalPreference, nullsLast(Long::compareTo))
          .thenComparing(RouteRowAttribute::getOriginProtocol, nullsLast(String::compareTo))
          .thenComparing(
              RouteRowAttribute::getOriginMechanism, nullsLast(OriginMechanism::compareTo))
          .thenComparing(RouteRowAttribute::getOriginType, nullsLast(OriginType::compareTo))
          .thenComparing(RouteRowAttribute::getReceivedFromIp, nullsLast(Ip::compareTo))
          .thenComparing(RouteRowAttribute::getTag, nullsLast(Long::compareTo))
          .thenComparing(RouteRowAttribute::getStatus, nullsLast(BgpRouteStatus::compareTo))
          .thenComparing(
              routeRowAttribute -> routeRowAttribute.getCommunities().toString(),
              nullsLast(String::compareTo))
          .thenComparing(RouteRowAttribute::getWeight, Comparator.nullsLast(Integer::compareTo));

  @Override
  public int compareTo(RouteRowAttribute o) {
    return COMPARATOR.compare(this, o);
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    RouteRowAttribute that = (RouteRowAttribute) o;
    return Objects.equals(_nextHopInterface, that._nextHopInterface)
        && Objects.equals(_adminDistance, that._adminDistance)
        && Objects.equals(_metric, that._metric)
        && Objects.equals(_asPath, that._asPath)
        && Objects.equals(_localPreference, that._localPreference)
        && Objects.equals(_communities, that._communities)
        && Objects.equals(_originProtocol, that._originProtocol)
        && Objects.equals(_originMechanism, that._originMechanism)
        && Objects.equals(_originType, that._originType)
        && Objects.equals(_receivedFromIp, that._receivedFromIp)
        && Objects.equals(_tag, that._tag)
        && Objects.equals(_status, that._status)
        && Objects.equals(_weight, that._weight);
  }

  @Override
  public int hashCode() {
    return Objects.hash(
        _nextHopInterface,
        _adminDistance,
        _metric,
        _asPath,
        _localPreference,
        _communities,
        _originProtocol,
        _originType == null ? 0 : _originType.ordinal(),
        _receivedFromIp,
        _tag,
        _status == null ? 0 : _status.ordinal(),
        _weight);
  }

  /** Builder for {@link RouteRowAttribute} */
  public static final class Builder {
    @Nullable private String _nextHopInterface;
    @Nullable private Integer _adminDistance;
    @Nullable private Long _metric;
    @Nullable private AsPath _asPath;
    @Nullable private Long _localPreference;
    @Nullable private List<String> _communities;
    @Nullable private String _originProtocol;
    @Nullable private OriginMechanism _originMechanism;
    @Nullable private OriginType _originType;
    @Nullable private Ip _receivedFromIp;
    @Nullable private Long _tag;
    @Nullable private BgpRouteStatus _status;
    @Nullable private Integer _weight;

    public RouteRowAttribute build() {
      if (_tag != null && _tag == Route.UNSET_ROUTE_TAG) {
        _tag = null;
      }
      return new RouteRowAttribute(
          _nextHopInterface,
          _adminDistance,
          _metric,
          _asPath,
          _localPreference,
          _communities,
          _originProtocol,
          _originMechanism,
          _originType,
          _receivedFromIp,
          _tag,
          _status,
          _weight);
    }

    public Builder setAdminDistance(Integer adminDistance) {
      _adminDistance = adminDistance;
      return this;
    }

    public Builder setMetric(Long metric) {
      _metric = metric;
      return this;
    }

    public Builder setAsPath(AsPath asPath) {
      _asPath = asPath;
      return this;
    }

    public Builder setLocalPreference(Long localPreference) {
      _localPreference = localPreference;
      return this;
    }

    public Builder setCommunities(List<String> communities) {
      _communities = communities;
      return this;
    }

    public Builder setNextHopInterface(String nextHopInterface) {
      _nextHopInterface = nextHopInterface;
      return this;
    }

    public Builder setOriginProtocol(String originProtocol) {
      _originProtocol = originProtocol;
      return this;
    }

    public Builder setOriginMechanism(OriginMechanism originMechanism) {
      _originMechanism = originMechanism;
      return this;
    }

    public Builder setOriginType(OriginType originType) {
      _originType = originType;
      return this;
    }

    public Builder setReceivedFromIp(Ip receivedFromIp) {
      _receivedFromIp = receivedFromIp;
      return this;
    }

    public Builder setTag(Long tag) {
      _tag = tag;
      return this;
    }

    public Builder setStatus(BgpRouteStatus status) {
      _status = status;
      return this;
    }

    public Builder setWeight(Integer weight) {
      _weight = weight;
      return this;
    }
  }
}
