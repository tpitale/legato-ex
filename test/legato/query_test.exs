defmodule Legato.QueryTest do
  use ExUnit.Case
  doctest Legato.Query

  # test "add metrics to query" do
  #   query = %Legato.Query{}

  #   assert query.metrics == []

  #   query = Legato.Query.metrics(query, [:exits])

  #   assert query.metrics == [:exits]
  # end

  # test "add dimensions to query" do
  #   query = %Legato.Query{}

  #   assert query.dimensions == []

  #   query = Legato.Query.dimensions(query, [:country])

  #   assert query.dimensions == [:country]
  # end
end
