# may be unecessary
defmodule Legato.Request do
  def all(query) do
    Legato.Client.post(query)
  end
end
