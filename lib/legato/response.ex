defmodule Legato.Response do
  def build({:ok, %HTTPoison.Response{body: body, headers: _headers}}) do
    Poison.decode!(body) |> as_report
  end

  defp as_report(%{"error" => errors}) do
    IO.inspect errors
  end

  defp as_report(%{"reports" => reports}) do
    Legato.Report.from_json(reports)
  end
end
