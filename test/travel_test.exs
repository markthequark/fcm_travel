defmodule TravelTest do
  use ExUnit.Case, async: true

  test "display_itinerary/0" do
    ExUnit.CaptureIO.capture_io(fn ->
      assert Travel.display_itinerary() ==
               """
               TRIP to BCN
               Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
               Hotel at BCN on 2023-01-05 to 2023-01-10
               Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

               TRIP to MAD
               Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
               Hotel at MAD on 2023-02-15 to 2023-02-17
               Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

               TRIP to NYC, BOS
               Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
               Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
               Flight from NYC to BOS at 2023-03-06 08:00 to 09:25
               """
               |> String.trim()
    end)
  end
end
