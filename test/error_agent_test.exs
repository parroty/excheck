defmodule ExCheck.ErrorAgentTest do
  use ExUnit.Case, async: false
  alias ExCheck.ErrorAgent, as: ErrAgent

  test "Starting and stopping agent" do
    {:ok, agent} = ErrAgent.start_link
    assert Process.alive?(agent)
    ErrAgent.stop(agent)
    refute Process.alive?(agent)
  end

  test "Adding and flushing errors" do
    me = self()
    other = spawn fn -> :ok end
    {:ok, agent} = ErrAgent.start_link
    # Errors could contain anything, using text for simplicity
    {err1, err2, err3, err4} = {"err1", "err2", "err3", "err4"}

    assert ErrAgent.flush_errors(agent) == []
    agent |> ErrAgent.add_error(me, err1)
    assert ErrAgent.flush_errors(agent) == [[err1]]
    assert ErrAgent.flush_errors(agent) == []
    agent |> ErrAgent.add_error(me, err1)
    agent |> ErrAgent.add_error(me, err2)
    assert ErrAgent.flush_errors(agent) == [[err1, err2]]
    agent |> ErrAgent.add_error(me, err1)
    agent |> ErrAgent.add_error(other, err3)
    agent |> ErrAgent.add_error(other, err4)
    assert ErrAgent.flush_errors(agent) == [[err1], [err3, err4]]
  end
end
