# may be unecessary
defmodule Legato.Request do
  defstruct body: "", access_token: ""

  def all(query) do
    request = %{body: Legato.Query.to_json(query), access_token: query.profile.access_token}

    request |>
      Legato.Client.post |>
      Legato.Response.build
  end
end
