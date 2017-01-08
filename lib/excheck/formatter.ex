defmodule ExCheck.Formatter do
  @version140_or_later Version.compare(System.version, "1.4.0") in [:gt, :eq]

  if @version140_or_later do
    use GenServer
  else
    use GenEvent
  end

  alias ExUnit.CLIFormatter, as: CF

  @moduledoc """
  Helper module for properly formatting test output.

  This formatter implements a GenEvent based ExUnit formatter when an Elixir version prior to 1.4.0
  is used, and otherwise implements a GenServer based formatter.
  """

  @doc false
  def init(opts) do
    CF.init(opts)
  end

  if @version140_or_later do

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

  else

    @doc false
    def handle_event(event = {:suite_finished, _run_us, _load_us}, config) do
      updated_tests_count = update_tests_counter(config.tests_counter)
      new_cfg = %{config | tests_counter: updated_tests_count}
      print_property_test_errors()
      CF.handle_event(event, new_cfg)
    end
    def handle_event(event, config) do
      CF.handle_event(event, config)
    end

  end

  defp print_property_test_errors do
    ExCheck.IOServer.errors
    |> List.flatten
    |> Enum.map(fn({msg, value_list}) ->
      :io.format(msg, value_list)
    end)
  end

  defp update_tests_counter(tests_counter) when is_integer(tests_counter) do
    total_tests = tests_counter + ExCheck.IOServer.total_tests
    ExCheck.IOServer.reset_test_count
    total_tests
  end
  defp update_tests_counter(tests_counter) when is_map(tests_counter) do
    total_tests = %{tests_counter | test: tests_counter.test + ExCheck.IOServer.total_tests}
    ExCheck.IOServer.reset_test_count
    total_tests
  end
end
