defmodule Travel.FileReader do
  @moduledoc """
  Functions for reading and parsing users' reservations from a file
  """

  alias Travel.Trip.Segment

  @doc """
  Parses a user's reservations from the given filepath and returns the user's base location and
  all their reservations represented as Segments. Raises if the file cannot be read or is not
  formatted correctly.
  """
  @spec parse!(filepath) :: %{base: base, segments: segments} | no_return
        when filepath: Path.t(),
             base: Segment.location(),
             segments: [Segment.t()]
  def parse!(filepath) do
    binary = File.read!(filepath)
    lines = String.split(binary, ["\r", "\n", "RESERVATION"], trim: true)

    ["BASED: " <> base | segment_lines] = lines
    segments = Enum.map(segment_lines, &parse_segment!/1)

    %{base: base, segments: segments}
  end

  @spec parse_segment!(String.t()) :: Segment.t()
  defp parse_segment!(encoded_segment)

  defp parse_segment!("SEGMENT: Flight " <> encoded_flight) do
    parse_segment!(encoded_flight, :flight)
  end

  defp parse_segment!("SEGMENT: Train " <> encoded_train) do
    parse_segment!(encoded_train, :train)
  end

  defp parse_segment!("SEGMENT: Hotel " <> encoded_hotel) do
    parse_segment!(encoded_hotel, :hotel)
  end

  @spec parse_segment!(String.t(), Segment.segment_type()) :: Segment.t()
  defp parse_segment!(encoded_segment, type)

  defp parse_segment!(encoded_flight_or_train, type) when type in [:flight, :train] do
    <<from::binary-size(3), " ", depart_date::binary-size(10), " ", depart_time::binary-size(5),
      " -> ", to::binary-size(3), " ", arrive_time::binary-size(5)>> = encoded_flight_or_train

    %Segment{
      type: type,
      start_location: from,
      end_location: to,
      starts_at: to_datetime(depart_date, depart_time),
      ends_at: to_datetime(depart_date, arrive_time)
    }
  end

  defp parse_segment!(encoded_hotel, :hotel) do
    <<location::binary-size(3), " ", start_date::binary-size(10), " -> ",
      end_date::binary-size(10)>> = encoded_hotel

    %Segment{
      type: :hotel,
      start_location: location,
      end_location: location,
      starts_at: to_datetime(start_date, "00:00:00"),
      ends_at: to_datetime(end_date, "00:00:00")
    }
  end

  @spec to_datetime(String.t(), String.t()) :: DateTime.t()
  defp to_datetime(<<date::binary-size(10)>>, <<time::binary-size(5)>>) do
    to_datetime(date, time <> ":00")
  end

  defp to_datetime(<<date::binary-size(10)>>, <<time::binary-size(8)>>) do
    date = Date.from_iso8601!(date)
    time = Time.from_iso8601!(time)
    DateTime.new!(date, time)
  end
end
