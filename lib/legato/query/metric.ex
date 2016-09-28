defmodule Legato.Query.Metric do
  @derive [Poison.Encoder]
  defstruct expression: nil, alias: nil, formatting_type: nil

  # formatting type is (INTEGER, FLOAT, CURRENCY, PERCENT, TIME)

  @doc ~S"""
  Adds names or expressions to a list

  ## Examples

    iex> Legato.Query.Metric.add([], [:pageviews])
    [%Legato.Query.Metric{expression: "ga:pageviews"}]

    iex> Legato.Query.Metric.add([], [:pageviews, :exits])
    [%Legato.Query.Metric{expression: "ga:pageviews"}, %Legato.Query.Metric{expression: "ga:exits"}]

    iex> Legato.Query.Metric.add([], [:pageviews, :pageviews])
    [%Legato.Query.Metric{expression: "ga:pageviews"}]

    iex> Legato.Query.Metric.add([], ["ga:pageviews"])
    [%Legato.Query.Metric{expression: "ga:pageviews"}]

    iex> Legato.Query.Metric.add([], ["ga:pageviews/ga:exits", :pageviews])
    [%Legato.Query.Metric{expression: "ga:pageviews/ga:exits"}, %Legato.Query.Metric{expression: "ga:pageviews"}]

  """
  def add(metrics, names) do
    uniq_by_name(metrics ++ build(names))
  end

  defp build(names) when is_list(names) do
    Enum.map(names, fn(name) -> build(name) end)
  end

  defp build(name) when is_atom(name) do
    build(Legato.add_prefix(name))
  end

  defp build(name) do
    %__MODULE__{expression: name}
  end

  defp uniq_by_name(metrics) do
    Enum.uniq_by(metrics, fn(m) -> m.expression end)
  end
end
