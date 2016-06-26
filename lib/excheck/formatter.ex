defmodule ExCheck.Formatter do
  use GenEvent
  alias ExUnit.CLIFormatter, as: CF

  @moduledoc """
  Helper module for properly formatting test output.
  """

  @doc false
  def init(opts) do
    CF.init(opts)
  end

  @doc false
  def handle_event(event = {:suite_finished, _run_us, _load_us}, config) do
    updated_test_count = config.tests_counter.test + ExCheck.IOServer.total_tests
    new_cfg = %{config | tests_counter: %{test: updated_test_count}}
    print_property_test_errors
    CF.handle_event(event, new_cfg)
  end
  def handle_event(event, config) do
    CF.handle_event(event, config)
  end

  defp print_property_test_errors do
    ExCheck.IOServer.errors
    |> List.flatten
    |> Enum.map(fn({msg, value_list}) ->
      :io.format(msg, value_list)
    end)
  end
end
