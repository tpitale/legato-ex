defmodule Legato.Query do
  defstruct profile: nil,
            view_id: nil,
            metrics: [],
            dimensions: [],
            filters: %{
              metrics: %Legato.Query.FilterSet{},
              dimensions: %Legato.Query.FilterSet{}
            },
            segments: [],
            date_ranges: []

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
  alias Legato.Query.MetricFilter
  alias Legato.Query.Dimension
  alias Legato.Query.DimensionFilter
  alias Legato.Query.FilterSet

  # @behaviour Access
  # def fetch(t, key) do
  # end
  # def get(t, key, value) do
  # end
  # def get_and_update(t, key, list) do
  # end
  # def pop(t, key) do
  # end

  # TODO: metrics, dimensions calls that start with a profile

  # TODO: metric list module?

  @doc ~S"""
  Start a query with a given Legato.Profile and metrics

  ## Examples

    iex> %Legato.Profile{access_token: "abcde", view_id: 177817} |> Legato.Query.metrics([:pageviews])
    %Legato.Query{
      profile: %Legato.Profile{access_token: "abcde", view_id: 177817},
      view_id: 177817,
      metrics: [%Legato.Query.Metric{expression: "ga:pageviews"}]
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
      metrics: [%Legato.Query.Metric{expression: "ga:pageviews"}, %Legato.Query.Metric{expression: "ga:exits"}]
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
      dimensions: [%Legato.Query.Dimension{name: "ga:country"}]
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
      dimensions: [%Legato.Query.Dimension{name: "ga:country"}, %Legato.Query.Dimension{name: "ga:city"}]
    }

  """
  def dimensions(%__MODULE__{} = query, names) do
    %{query | dimensions: Dimension.add(query.dimensions, names)}
  end

  def filter(query, :metrics, %MetricFilter{} = filter) do
    update_in(query.filters.metrics, &FilterSet.add(&1, filter))
  end

  def filter(query, :dimensions, %DimensionFilter{} = filter) do
    update_in(query.filters.dimensions, &FilterSet.add(&1, filter))
  end

  @doc ~S"""
  Add filter with default operator

  ## Examples

    iex> %Legato.Query{} |> Legato.Query.filter(:metrics, :pageviews)
  """
  def filter(query, as, name) do
    filter(query, as, name, nil)
  end

  def filter(query, :metrics, name, operator) do
    filter(query, :metrics, %MetricFilter{
      metric_name: name,
      operator: (operator || :equal)
    })
  end

  def filter(query, :dimensions, name, operator) do
    filter(query, :dimensions, %DimensionFilter{
      dimension_name: name,
      operator: (operator || :regexp)
    })
  end

  # TODO: date_range
  # TODO: add_date_range

  # TODO: validate presence of profile, view_id, metrics, dimensions

  def to_json(query), do: Poison.encode!(query)
end
