defmodule Legato.Query.DimensionFilter do
  defstruct dimension_name: nil, not: false, operator: :regexp, expressions: [], case_sensitive: false
end
