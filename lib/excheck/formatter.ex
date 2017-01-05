defmodule ExCheck.Formatter do
  use GenServer
  alias ExUnit.CLIFormatter, as: CF

  @moduledoc """
  Helper module for properly formatting test output.
  """

  @doc false
  def init(opts) do
    CF.init(opts)
  end

  @doc false
  def handle_cast(event = {:suite_finished, _run_us, _load_us}, config) do
    updated_tests_count = update_tests_counter(config.test_counter)
    new_cfg = %{config | test_counter: updated_tests_count}
    print_property_test_errors()
    CF.handle_cast(event, new_cfg)
  end
  def handle_cast(event, config) do
    CF.handle_cast(event, config)
  end

  defp print_property_test_errors do
    ExCheck.IOServer.errors
    |> List.flatten
    |> Enum.map(fn({msg, value_list}) ->
      :io.format(msg, value_list)
    end)
  end

  defp update_tests_counter(test_counter) when is_integer(test_counter) do
    total_tests = test_counter + ExCheck.IOServer.total_tests
    ExCheck.IOServer.reset_test_count
    total_tests
  end
  defp update_tests_counter(test_counter) when is_map(test_counter) do
    total_tests = %{test_counter | test: test_counter.test + ExCheck.IOServer.total_tests}
    ExCheck.IOServer.reset_test_count
    total_tests
  end
end
