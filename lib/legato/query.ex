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

  def metrics(%Profile{} = profile, names) do
    %__MODULE__{profile: profile, view_id: profile.view_id} |> metrics(names)
  end

  def metrics(%__MODULE__{} = query, names) do
    %{query | metrics: Metric.add(query.metrics, names)}
  end

  def dimensions(%Profile{} = profile, names) do
    %__MODULE__{profile: profile, view_id: profile.view_id} |> dimensions(names)
  end

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
