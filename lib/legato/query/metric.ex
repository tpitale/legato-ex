defmodule Legato.Query.Metric do
  @derive [Poison.Encoder]
  defstruct expression: nil, alias: nil, formatting_type: nil

  # formatting type is (INTEGER, FLOAT, CURRENCY, PERCENT, TIME)

  def add(metrics, names) do
    uniq_by_name(metrics ++ build(names))
  end

  defp build(names) when is_list(names) do
    Enum.map(names, fn(name) -> build(name) end)
  end

  defp build(name) do
    %{expression: name}
  end

  defp uniq_by_name(metrics) do
    Enum.uniq_by(metrics, fn(m) -> m.expression end)
  end
end
