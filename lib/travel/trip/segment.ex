defmodule Travel.Trip.Segment do
  @moduledoc """
  Represents a segment of a user's trip, such as a single flight or a train journey.
  """

  use TypedStruct

  @type location :: <<_::24>>
  @type segment_type :: :flight | :train | :hotel

  typedstruct enforce: true do
    @typedoc "A segment of a user's trip"

    field :type, segment_type
    field :start_location, location
    field :end_location, location
    field :starts_at, DateTime.t()
    field :ends_at, DateTime.t()
  end

  @doc """
  Compares two segment structs.

  Returns :gt if segment1 starts after segment2, and :lt if segment1 starts before segment2.
  If segments start at the same time:
  Returns :gt if segment1 ends after segment2, and :lt if segment1 ends before segment2.

  When comparing hotel segments with any segment type, only the date portion
  of the starts_at and ends_at fields are considered, ignoring the time.
  """
  @spec compare(t(), t()) :: :lt | :eq | :gt
  def compare(segment1, segment2)

  def compare(segment1, segment2) when segment1.type == :hotel or segment2.type == :hotel do
    with :eq <- Date.compare(segment1.starts_at, segment2.starts_at) do
      Date.compare(segment1.ends_at, segment2.ends_at)
    end
  end

  def compare(segment1, segment2) do
    with :eq <- DateTime.compare(segment1.starts_at, segment2.starts_at) do
      DateTime.compare(segment1.ends_at, segment2.ends_at)
    end
  end

  @spec to_human_readable_string(t()) :: String.t()
  def to_human_readable_string(%__MODULE__{type: :hotel} = segment) do
    "Hotel at #{segment.end_location} on #{DateTime.to_date(segment.starts_at)} " <>
      "to #{DateTime.to_date(segment.ends_at)}"
  end

  def to_human_readable_string(%__MODULE__{} = segment) do
    type = segment.type |> to_string() |> String.capitalize()
    not_equal_dates? = not (Date.compare(segment.starts_at, segment.ends_at) == :eq)
    date1 = Date.to_string(segment.starts_at)
    date2 = Date.to_string(segment.ends_at)
    time1 = Time.to_string(segment.starts_at) |> without_seconds()
    time2 = Time.to_string(segment.ends_at) |> without_seconds()

    "#{type} from #{segment.start_location} to #{segment.end_location} " <>
      "at #{date1} #{time1} to#{if not_equal_dates?, do: " #{date2}"} #{time2}"
  end

  @spec without_seconds(String.t()) :: String.t()
  defp without_seconds(<<hours_and_minutes::binary-size(5), _rest::binary>>) do
    hours_and_minutes
  end
end
