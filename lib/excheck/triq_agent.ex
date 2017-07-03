defmodule ExCheck.TriqAgent do
  defstruct tests_count: 0

  alias __MODULE__

  def start_link do
    Agent.start_link fn -> %TriqAgent{} end, name: __MODULE__
  end

  def update_tests_count(count) do
    Agent.update(__MODULE__, fn(%{tests_count: c} = state) ->
      %{state | tests_count: c + count} 
    end)
  end

  def get_tests_count() do
    Agent.get_and_update(__MODULE__, fn(%{tests_count: c} = state) ->
      {c, %{state | tests_count: 0}}
    end)
  end
end
