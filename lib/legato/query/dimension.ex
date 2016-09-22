defmodule Legato.Query.Dimension do
  @derive [Poison.Encoder]
  defstruct name: nil

  def add(dimensions, names) do
    uniq_by_name(dimensions ++ build(names))
  end

  defp build(names) when is_list(names) do
    Enum.map(names, fn(name) -> build(name) end)
  end

  defp build(name) do
    %{name: name}
  end

  defp uniq_by_name(dimensions) do
    Enum.uniq_by(dimensions, fn(m) -> m.name end)
  end
end
