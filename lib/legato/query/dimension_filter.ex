defmodule Legato.Query.DimensionFilter do
  defstruct dimension_name: nil, not: false, operator: :regexp, expressions: [], case_sensitive: false


  # {
  #   "dimensionName": string,
  #   "not": boolean,
  #   "operator": enum(Operator),
  #   "expressions": [
  #     string
  #   ],
  #   "caseSensitive": boolean,
  # }
  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do
      # This is the format for GA report json
      Poison.Encoder.Map.encode(%{
        dimension_name: struct.dimension_name,
        operator: struct.operator,
        expressions: struct.expressions,
        not: struct.not,
        case_sensitive: struct.case_sensitive
      }, options)
    end
  end

  def to_json(filter), do: Poison.encode!(filter)
end
