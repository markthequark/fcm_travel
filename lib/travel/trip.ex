defmodule Travel.Trip do
  @moduledoc """
  A series of reservations made by a user that begins and ends at their base location.
  A Trip is Made up of Segments
  """

  alias Travel.Trip.Segment

  @type t :: [Segment.t(), ...]

  @doc """
  Takes a list of segments and groups them into trips.

  The last trip returned by this function may be incomplete and therefore may not end
  at the user's base location.
  """
  @spec segments_to_trips(segments, base) :: trips
        when segments: [Segment.t()],
             base: Segment.location(),
             trips: [t()]
  def segments_to_trips(segments, base) do
    segments = Enum.sort(segments, Segment)

    chunk_fun = fn segment, acc ->
      if segment.end_location == base do
        {:cont, Enum.reverse([segment | acc]), []}
      else
        {:cont, [segment | acc]}
      end
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    Enum.chunk_while(segments, [], chunk_fun, after_fun)
  end

  @doc """
  Returns the destinations of a trip.
  A destination of a trip is any location stayed in for longer than 24 hours excluding
  the starting location.
  """
  @spec destinations(trip) :: destinations
        when trip: t(),
             destinations: [Segment.location()]
  def destinations(trip) do
    [%Segment{start_location: start_location} | _] = trip
    destinations(trip, start_location, [])
  end

  defp destinations([], start_location, acc) do
    acc
    |> Enum.reject(&(&1 == start_location))
    |> Enum.reverse()
  end

  defp destinations([final_segment], start_location, acc) do
    destinations([], start_location, [final_segment.end_location | acc])
  end

  defp destinations([%Segment{type: :hotel} = hotel | _] = trip, start_location, acc) do
    destinations(tl(trip), start_location, [hotel.end_location | acc])
  end

  defp destinations([segment1, segment2 | _] = trip, start_location, acc) do
    if DateTime.diff(segment2.starts_at, segment1.ends_at, :hour) > 24 do
      destinations(tl(trip), start_location, [segment1.end_location | acc])
    else
      destinations(tl(trip), start_location, acc)
    end
  end

  @spec to_human_readable_string(t()) :: String.t()
  def to_human_readable_string(trip) do
    destinations = destinations(trip) |> Enum.join(", ")
    header = "TRIP to #{destinations}\n"
    rest = Enum.map_join(trip, "\n", &Segment.to_human_readable_string/1)

    header <> rest
  end
end
