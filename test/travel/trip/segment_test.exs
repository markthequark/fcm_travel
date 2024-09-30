defmodule Travel.Trip.SegmentTest do
  use ExUnit.Case, async: true
  alias Travel.Factory
  alias Travel.Trip.Segment

  describe "compare/2" do
    test "a segment with later start time is greater" do
      now = DateTime.utc_now()
      segment = Factory.build(:flight_segment, starts_at: now)
      later_segment = Factory.build(:flight_segment, starts_at: DateTime.add(now, 1, :hour))

      assert Segment.compare(segment, later_segment) == :lt
      assert Segment.compare(later_segment, segment) == :gt
    end

    test "a segment with later end time and same start time is greater" do
      now = DateTime.utc_now()
      segment = Factory.build(:flight_segment, starts_at: now, ends_at: now)

      later_segment =
        Factory.build(:flight_segment, starts_at: now, ends_at: DateTime.add(now, 1, :hour))

      assert Segment.compare(segment, later_segment) == :lt
      assert Segment.compare(later_segment, segment) == :gt
    end

    for {factory, segment_name} <- [flight_segment: "flight", train_segment: "train"] do
      test "hotels == #{segment_name}s for segments with same start and end date but different times" do
        starts_at = Date.utc_today()
        ends_at = Date.add(starts_at, 1)
        hotel = Factory.build(:hotel_segment, starts_at: starts_at, ends_at: ends_at)

        starts_at = DateTime.new!(starts_at, ~T[00:00:00])
        ends_at = DateTime.new!(ends_at, ~T[00:00:00])
        flight_or_train = Factory.build(unquote(factory), starts_at: starts_at, ends_at: ends_at)

        assert Segment.compare(hotel, flight_or_train) == :eq
      end
    end

    for segment_type <- ~w(flight_segment train_segment hotel_segment)a do
      test "#{segment_type}s with same start and end time are equal" do
        segment = Factory.build(unquote(segment_type))

        segment2 =
          Factory.build(unquote(segment_type),
            starts_at: segment.starts_at,
            ends_at: segment.ends_at
          )

        assert Segment.compare(segment, segment2) == :eq
        assert Segment.compare(segment2, segment) == :eq
      end
    end
  end
end
