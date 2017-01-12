defmodule ExCheck.ErrorAgent do
  @moduledoc """
  Agent which stores errors untill all tests are finished.
  """

  @initial_state %{}

  @doc "Start the agent and link it to the calling process."
  def start_link do
    Agent.start_link fn -> @initial_state end
  end

  @doc "Saves an error message."
  def add_error(agent, pid, msg) do
    agent |> Agent.update(fn(state) ->
      error_msgs = Map.get(state, pid, [])
      Map.put(state, pid, [msg | error_msgs])
    end)
  end

  @doc "Return all errors stored by this agent."
  def flush_errors(agent) do
    agent |> Agent.get_and_update(fn(state) ->
      {
        state |> Enum.map(fn {_pid, errors} ->
          Enum.reverse(errors)  # Errors are stored in reverse
        end),
        @initial_state
      }
    end)
  end

  @doc "Stops the agent."
  def stop(agent) do
    Agent.stop(agent)
  end
end
