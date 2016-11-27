defmodule Legato.Query.FilterSet do
  defstruct operator: :or, filters: [] #, for: :metrics

  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do
      # This is the format for GA report json
      Poison.Encoder.Map.encode(%{
        operator: Legato.Query.FilterSet.operator_string(struct),
        filters: Enum.reverse(struct.filters)
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
    # %{set | filters: [filter | set.filters]}
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
end
