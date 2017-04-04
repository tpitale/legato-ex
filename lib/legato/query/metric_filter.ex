defmodule Legato.Query.MetricFilter do
  defstruct metric_name: nil, not: false, operator: :equal, comparison_value: nil

  # {
  #   "metricName": string,
  #   "not": boolean,
  #   "operator": enum(Operator),
  #   "comparisonValue": string,
  # }
  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do
      # This is the format for GA report json
      Poison.Encoder.Map.encode(%{
        metric_name: struct.dimension_name,
        operator: struct.operator,
        not: struct.not,
        comparison_value: struct.comparison_value
      }, options)
    end
  end

  def to_json(filter), do: Poison.encode!(filter)
end
