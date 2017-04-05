defmodule Legato do
  # def add_prefix(keys, prefix \\ "ga") when is_list(keys) do
  #   Enum.map(keys, &add_prefix(&1, prefix))
  # end

  def add_prefix(key, prefix \\ "ga")
  def add_prefix(key, prefix) when is_integer(key), do: add_prefix(to_string(key), prefix)
  def add_prefix(key, prefix), do: Enum.join([prefix, key], ":")
end
