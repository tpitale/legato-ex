defmodule Legato.Query.MetricFilter do
  defstruct metric_name: nil, not: false, operator: :equal, comparison_value: nil
end
