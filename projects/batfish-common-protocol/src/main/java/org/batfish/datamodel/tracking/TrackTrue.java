package org.batfish.datamodel.tracking;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import javax.annotation.Nonnull;

/** A track that always matches. Placeholder for unsupported vendor track methods. */
public final class TrackTrue implements TrackMethod {

  @JsonCreator
  @JsonValue
  public static @Nonnull TrackTrue instance() {
    return INSTANCE;
  }

  @Override
  public <R> R accept(GenericTrackMethodVisitor<R> visitor) {
    return visitor.visitTrackTrue(this);
  }

  @Override
  public boolean equals(Object obj) {
    return this == obj || obj instanceof TrackTrue;
  }

  @Override
  public int hashCode() {
    return 0x6D7DC4CB; // randomly generated
  }

  private static @Nonnull TrackTrue INSTANCE = new TrackTrue();

  private TrackTrue() {}
}
