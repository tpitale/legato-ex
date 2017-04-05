# may be unecessary
defmodule Legato.Request do
  defstruct body: "", access_token: ""

  def all(query) do
    from_query(query) |>
      Legato.Client.post |>
      Legato.Response.build
  end

  defp from_query(query) do
    %__MODULE__{body: Legato.Query.to_json(query), access_token: query.profile.access_token}
  end
end
