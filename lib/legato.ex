defmodule Legato do
  def add_prefix(keys, prefix \\ "ga") when is_list(keys) do
    Enum.map(keys, fn(key) -> Enum.join([prefix, key], ":") end)
  end
end
