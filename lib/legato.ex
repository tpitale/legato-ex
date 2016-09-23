defmodule Legato do
  # def add_prefix(keys, prefix \\ "ga") when is_list(keys) do
  #   Enum.map(keys, fn(key) -> add_prefix(key, prefix) end)
  # end

  def add_prefix(key, prefix \\ "ga") when is_atom(key) do
    Enum.join([prefix, key], ":")
  end
end
