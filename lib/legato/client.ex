defmodule Legato.Client do
  @url "https://analyticsreporting.googleapis.com/v4/reports:batchGet"

  def post(request) do
    HTTPoison.post @url, request.body, [
      {"Authorization", "Bearer #{request.access_token}"}
    ]
  end
end
