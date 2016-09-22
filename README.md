# Legato

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `legato` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:legato, "~> 0.1.0"}]
    end
    ```

  2. Ensure `legato_ex` is started before your application:

    ```elixir
    def application do
      [applications: [:legato]]
    end
    ```

```elixir
profile = %User{access_token: access_token} |> Profile.all |> Enum.first
report = %Report{dimensions: [], metrics: []}

import Legato::Query
```

Get an oauth access token

"Authorization: Bearer token_here"

HTTPoison.post "https://analyticsreporting.googleapis.com/v4/reports:batchGet", "{}", [{"Authorization", "Bearer token_here"}]

1. Collect data into Query struct
2. Convert query into ReportRequest JSON, encode with Poison
3. Send request to GA
4. Decode response
5. Parse data into Report struct

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
