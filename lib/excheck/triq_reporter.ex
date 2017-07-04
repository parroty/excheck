defmodule ExCheck.TriqReporter do

  def report(:pass, _) do
    IO.write colorize(:blue, "_")
  end
  def report(:check_failed, [count, _error]) do
    :ok = ExCheck.TriqAgent.update_tests_count(count)
  end
  def report(:success, count) do
    :ok = ExCheck.TriqAgent.update_tests_count(count)
  end
  def report(:counterexample, _counter_example), do: nil
  def report(:skip, _), do: nil
  def report(:testing, [_module, _fun]), do: nil
  def report(:fail, false), do: nil
  def report(:fail, _value), do: nil

  # FIXME colors must be made optional
  defp colorize(escape, string) do
    [escape, string, :reset]
    |> IO.ANSI.format_fragment(true)
    |> IO.iodata_to_binary
  end
end

