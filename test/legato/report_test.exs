defmodule Legato.ReportTest do
  use ExUnit.Case
  doctest Legato.Report

  defmodule ExitReport do
    defstruct exits: 0, pageviews: 0
  end

  test "applying struct to request results" do
    reports = [%{exits: 18, pageviews: 90}, %{pageviews: 10}] |> Legato.Report.as(ExitReport)
    expected = [
      %ExitReport{exits: 18, pageviews: 90},
      %ExitReport{exits: 0, pageviews: 10}
    ]

    assert reports == expected
  end
end
