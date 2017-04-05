defmodule Legato.Query.Segment do
  @derive [Poison.Encoder]
  defstruct segment_id: nil

  @id_prefix "gaid"

  def build(id) do
    %__MODULE__{segment_id: Legato.add_prefix(id, @id_prefix)}
  end
end
