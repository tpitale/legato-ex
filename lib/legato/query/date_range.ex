defmodule Legato.Query.DateRange do
  @derive [Poison.Encoder]
  defstruct start_date: nil, end_date: nil # strings, YYYY-MM-DD

  def add(date_ranges, start_date, end_date) do
    date_ranges ++ [%__MODULE__{start_date: start_date, end_date: end_date}]
  end
end
