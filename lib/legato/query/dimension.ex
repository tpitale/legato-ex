defmodule Legato.Query.Dimension do
  @derive [Poison.Encoder]
  defstruct name: nil, histogram_buckets: []

  @doc ~S"""
  Adds names to a list

  ## Examples

    iex> Legato.Query.Dimension.add([], [:country])
    [%Legato.Query.Dimension{name: "ga:country"}]

    iex> Legato.Query.Dimension.add([], [:country, :city])
    [%Legato.Query.Dimension{name: "ga:country"}, %Legato.Query.Dimension{name: "ga:city"}]

    iex> Legato.Query.Dimension.add([], [:country, :country])
    [%Legato.Query.Dimension{name: "ga:country"}]

    iex> Legato.Query.Dimension.add([], ["ga:country"])
    [%Legato.Query.Dimension{name: "ga:country"}]

  """

  def add(dimensions, names) do
    uniq_by_name(dimensions ++ build(names))
  end

  defp build(names) when is_list(names) do
    Enum.map(names, fn(name) -> build(name) end)
  end

  defp build(name) when is_atom(name) do
    build(Legato.add_prefix(name))
  end

  defp build(%__MODULE__{} = dimension) do
    dimension
  end

  defp build(name) do
    %__MODULE__{name: name}
  end

  defp uniq_by_name(dimensions) do
    Enum.uniq_by(dimensions, fn(m) -> m.name end)
  end
end
