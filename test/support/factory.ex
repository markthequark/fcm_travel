defmodule Travel.Factory do
  @moduledoc """
  Travel test data factory
  """

  use ExMachina
  alias Travel.Trip.Segment

  def up_char, do: Enum.random(?A..?Z)
  def iata, do: Stream.repeatedly(&up_char/0) |> Enum.take(3) |> to_string()

  def flight_segment_factory do
    starts_at = DateTime.utc_now()
    ends_at = DateTime.add(starts_at, Enum.random(1..12), :hour)

    %Segment{
      type: :flight,
      start_location: iata(),
      end_location: iata(),
      starts_at: starts_at,
      ends_at: ends_at
    }
  end

  def train_segment_factory do
    starts_at = DateTime.utc_now()
    ends_at = DateTime.add(starts_at, Enum.random(1..4), :hour)

    %Segment{
      type: :train,
      start_location: iata(),
      end_location: iata(),
      starts_at: starts_at,
      ends_at: ends_at
    }
  end

  def hotel_segment_factory do
    starts_at_date = Date.utc_today()
    ends_at_date = Date.add(starts_at_date, Enum.random(1..10))

    starts_at = DateTime.new!(starts_at_date, Time.new!(0, 0, 0))
    ends_at = DateTime.new!(ends_at_date, Time.new!(0, 0, 0))

    %Segment{
      type: :hotel,
      start_location: iata(),
      end_location: iata(),
      starts_at: starts_at,
      ends_at: ends_at
    }
  end

  def segment_factory do
    Enum.random([&flight_segment_factory/0, &train_segment_factory/0, &hotel_segment_factory/0])
    |> apply([])
  end
end
