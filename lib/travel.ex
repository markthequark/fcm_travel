defmodule Travel do
  @moduledoc """
  Solution to the FCM Digital Elixir technical challenge
  """

  alias Travel.Trip

  @doc """
  Parses reservations from a text file located at "priv/input.txt", sorts and groups
  them by trips from and back to a base location. Then displays them in a human
  readable format.
  """
  @spec display_itinerary() :: String.t() | no_return
  def display_itinerary do
    %{segments: segments, base: base} = Travel.FileReader.parse!("priv/input.txt")

    Trip.segments_to_trips(segments, base)
    |> Enum.map_join("\n\n", &Trip.to_human_readable_string/1)
    |> tap(&IO.puts/1)
  end
end
