defmodule Legato.Report do
  def from_json(reports) when is_list(reports) do
    Enum.map(reports, &from_json(&1))
  end

  def from_json(report) when is_map(report) do
    headers = headers_from_json(report["columnHeader"])

    values_from_json(report["data"]["rows"]) |>
      Enum.map(&map_row(headers, &1))
  end

  defp headers_from_json(headers) do
    # TODO: so much brittle JSON keys
    headers["dimensions"] ++ Enum.map(headers["metricHeader"]["metricHeaderEntries"], &parse_metric_header(&1))
  end

  defp parse_metric_header(header) do
    header["name"]
  end

  defp values_from_json(rows) do
    Enum.map(rows, &values_from_row(&1))
  end

  defp values_from_row(row) do
    row["dimensions"] ++ Enum.flat_map(row["metrics"], fn(m) -> m["values"] end)
  end

  defp map_row(headers, values) do
    Enum.zip(headers, values) |> Enum.into(%{})
  end
end
