defmodule Legato.Client do
  @url "https://analyticsreporting.googleapis.com/v4/reports:batchGet"

  def post(query) do
    HTTPoison.post @url,
      Legato.Query.to_json(query), # Encode query as json
      [{"Authorization", "Bearer #{query.profile.access_token}"}]
  end
end
