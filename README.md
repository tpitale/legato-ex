# Legato

Legato provides query access through the official [Google Analytics Reporting API v4](https://developers.google.com/analytics/devguides/reporting/core/v4/)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `legato` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:legato, "~> 0.1.0"}]
    end
    ```

  2. Ensure `legato` is started before your application:

    ```elixir
    def application do
      [applications: [:legato]]
    end
    ```

Get an oauth access token from Google

"Authorization: Bearer token_here"

HTTPoison.post "https://analyticsreporting.googleapis.com/v4/reports:batchGet", "{}", [{"Authorization", "Bearer token_here"}]

* [x] Collect data into Query struct
* [x] Convert query into Request JSON, encode with Poison
* [x] Send request to GA
* [x] Decode response
* [x] Parse data into struct
* [x] support metric expression strings
* [ ] add filters to Query
* [ ] add date ranges to Query
* [ ] add segments to Query
* [ ] put report struct into named struct

```elixir
profile = %Legato.Profile{access_token: oauth2_access_token, view_id: view_id}
```

```elixir
defmodule ExitReport do
  defstruct :exits, :pageviews, :country
end
```

```elixir
import Legato.Query

alias Legato.Request
alias Legato.Report

profile |>
  metrics([:exits, :pageviews]) |>
  dimensions([:country]) |>
  filter(:exits, :gt, 10) |>
  between(start_date, end_date) |>
Request.all |>
Report.as(ExitReport)
```
