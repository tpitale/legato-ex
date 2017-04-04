defmodule Legato.Query.DimensionFilter do
  defstruct dimension_name: nil, not: false, operator: :regexp, expressions: [], case_sensitive: false

  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do
      # This is the format for GA report json
      Poison.Encoder.Map.encode(%{
        dimension_name: struct.dimension_name,
        filters: Enum.reverse(struct.filters)
      }, options)
    end
  end
end
