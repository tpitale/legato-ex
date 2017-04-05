defmodule Legato.Report do
  def from_json(reports) when is_list(reports) do
    Enum.map(reports, &from_json(&1))
  end

  def from_json(report) when is_map(report) do
    headers = headers_from_json(report["columnHeader"])

    values_from_json(report) |>
      Enum.map(&map_row(headers, &1))
  end

  defp headers_from_json(%{"dimensions" => dimensions, "metricHeader" => %{"metricHeaderEntries" => metrics}}) do
    dimensions ++ Enum.map(metrics, fn(m) -> m["name"] end)
  end

  defp values_from_json(%{"data" => %{"rows" => rows}}) do
    Enum.map(rows, &values_from_row(&1))
  end

  defp values_from_row(%{"dimensions" => dimensions, "metrics" => metrics}) do
    dimensions ++ Enum.flat_map(metrics, fn(m) -> m["values"] end)
  end

  defp map_row(headers, values) do
    Enum.zip(headers, values) |> Enum.into(%{})
  end

  @doc ~S"""
  Convert plain map into named struct module

  ## Examples

    iex> defmodule ExitReport do
    ...>   defstruct exits: 0, pageviews: 0
    ...> end
    iex> [%{exits: 18, pageviews: 90}, %{pageviews: 10}] |> Legato.Report.as(ExitReport)
    [
      %ExitReport{exits: 18, pageviews: 90},
      %ExitReport{exits: 0, pageviews: 10}
    ]

  """
  def as(data, report_module) do
    Enum.map(data, &struct(report_module, &1))
  end
end
