defmodule Legato.Query do
  defstruct profile: nil, view_id: nil, metrics: [], dimensions: [], filters: [], segments: [], date_ranges: []

  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do

      # This is the format for GA report json
      # TODO: move into ReportRequest?
      Poison.Encoder.Map.encode(%{
        reportRequests: [
          %{
            view_id: to_string(struct.view_id),
            metrics: struct.metrics,
            dimensions: struct.dimensions
          }
        ]
      }, options)
    end
  end

  alias Legato.Profile
  alias Legato.Query.Metric
  alias Legato.Query.Dimension

  # TODO: metrics, dimensions calls that start with a profile

  # TODO: metric list module?

  @doc ~S"""
  Start a query with a given Legato.Profile and metrics

  ## Examples

    iex> %Legato.Profile{access_token: "abcde", view_id: 177817} |> Legato.Query.metrics([:pageviews])
    %Legato.Query{
      profile: %Legato.Profile{access_token: "abcde", view_id: 177817},
      view_id: 177817,
      metrics: [%Legato.Query.Metric{expression: "ga:pageviews"}],
      dimensions: [],
      filters: [],
      segments: [],
      date_ranges: []
    }

  """
  def metrics(%Profile{} = profile, names) do
    %__MODULE__{profile: profile, view_id: profile.view_id} |> metrics(names)
  end

  @doc ~S"""
  Add metrics to an existing Legato.Query

  ## Examples

    iex> %Legato.Query{} |> Legato.Query.metrics([:pageviews]) |> Legato.Query.metrics([:exits])
    %Legato.Query{
      profile: nil,
      view_id: nil,
      metrics: [%Legato.Query.Metric{expression: "ga:pageviews"}, %Legato.Query.Metric{expression: "ga:exits"}],
      dimensions: [],
      filters: [],
      segments: [],
      date_ranges: []
    }

  """
  def metrics(%__MODULE__{} = query, names) do
    %{query | metrics: Metric.add(query.metrics, names)}
  end

  @doc ~S"""
  Start a query with a given Legato.Profile and dimensions

  ## Examples

    iex> %Legato.Profile{access_token: "abcde", view_id: 177817} |> Legato.Query.dimensions([:country])
    %Legato.Query{
      profile: %Legato.Profile{access_token: "abcde", view_id: 177817},
      view_id: 177817,
      metrics: [],
      dimensions: [%Legato.Query.Dimension{name: "ga:country"}],
      filters: [],
      segments: [],
      date_ranges: []
    }

  """
  def dimensions(%Profile{} = profile, names) do
    %__MODULE__{profile: profile, view_id: profile.view_id} |> dimensions(names)
  end

  @doc ~S"""
  Add dimensions to an existing Legato.Query

  ## Examples

    iex> %Legato.Query{} |> Legato.Query.dimensions([:country]) |> Legato.Query.dimensions([:city])
    %Legato.Query{
      profile: nil,
      view_id: nil,
      metrics: [],
      dimensions: [%Legato.Query.Dimension{name: "ga:country"}, %Legato.Query.Dimension{name: "ga:city"}],
      filters: [],
      segments: [],
      date_ranges: []
    }

  """
  def dimensions(%__MODULE__{} = query, names) do
    %{query | dimensions: Dimension.add(query.dimensions, names)}
  end

  # TODO: struct for filter

  # def filter(query, :metrics, expr) do
  # end

  # def filter(query, :dimensions, expr) do
  # end

  # TODO: date_range
  # TODO: add_date_range

  # TODO: validate presence of profile, view_id, metrics, dimensions

  def to_json(query), do: Poison.encode!(query)
end
