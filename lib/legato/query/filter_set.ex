defmodule Legato.Query.FilterSet do
  defstruct operator: :or, filters: [], as: :metrics

  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do
      # This is the format for GA report json
      Poison.Encoder.Map.encode(%{
        Legato.Query.FilterSet.filter_clause_key(struct.as) => %{
          filters: Enum.reverse(struct.filters)
        },
        operator: Legato.Query.FilterSet.operator_string(struct)
      }, options)
    end
  end

  @doc ~S"""
  Add filters to an existing Legato.Query.FilterSet

  ## Examples

    iex> %Legato.Query.FilterSet{} |> Legato.Query.FilterSet.add(:a_filter)
    %Legato.Query.FilterSet{
      filters: [:a_filter],
      operator: :or
    }

  """
  def add(set, filter) do
    update_in(set.filters, &[filter | &1])
  end

  @doc ~S"""
  Return appropriate string for a given operator

  ## Examples

    iex> %Legato.Query.FilterSet{} |> Legato.Query.FilterSet.operator_string
    "OR"

    iex> %Legato.Query.FilterSet{operator: :and} |> Legato.Query.FilterSet.operator_string
    "AND"

  """
  def operator_string(set) do
    case set.operator do
      :or -> "OR"
      :and -> "AND"
    end
  end

  def to_json(filters), do: Poison.encode!(filters)

  def filter_clause_key(:metrics), do: :metricFilterClauses
  def filter_clause_key(:dimensions), do: :dimensionFilterClauses
end
