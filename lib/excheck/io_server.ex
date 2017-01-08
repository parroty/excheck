defmodule ExCheck.IOServer do
  use GenServer
  alias __MODULE__, as: State
  alias ExCheck.ErrorAgent, as: ErrAgent

  @moduledoc """
  Process which manipulates IO output and forwards it to previous group leader.
  """

  defstruct gl: :no_pid,     # Previous group leader process
            pids: [],        # The pids from which we are redirecting output
            tests: 0,        # Amount of triq property tests ran
            enabled: false,  # Colors enabled in terminal?
            agent: :no_pid

  @server __MODULE__

  # API

  @doc """
  Starts a new server process, links it to the calling process.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @server)
  end

  @doc "Redirects IO output from pid to this server."
  def redirect(pid) do
    @server |> GenServer.call({:redirect, pid})
  end

  @doc "Get the total amount of property tests that ran so far."
  def total_tests do
    @server |> GenServer.call(:total_tests)
  end

  @doc "Resets the test count."
  def reset_test_count do
    @server |> GenServer.call(:reset_test_count)
  end

  @doc "Returns all error loggings from property tests"
  def errors do
    @server |> GenServer.call(:errors)
  end

  # Callbacks

  @doc false
  def init(:ok) do
    {:ok, agent} = ErrAgent.start_link
    gl = Process.group_leader        # get previous group leader
    {:ok, %State{gl: gl, enabled: IO.ANSI.enabled?, agent: agent}}
  end

  @doc false
  def terminate(_reason, %State{gl: gl, pids: pids, agent: agent}) do
    for pid <- pids do
      Process.group_leader(pid, gl)  # Revert back to old group leader
    end
    ErrAgent.stop(agent)
    :ok
  end

  @doc false
  def handle_call({:redirect, pid}, _from, state = %State{pids: pids}) do
    Process.group_leader(pid, self())  # redirect all IO from pid to this process
    {:reply, :ok, %State{state | pids: [pid | pids]}}
  end
  def handle_call(:total_tests, _from, state = %State{tests: tests}) do
    {:reply, tests, state}
  end
  def handle_call(:reset_test_count, _from, state = %State{agent: agent}) do
    agent |> ErrAgent.clear_errors
    {:reply, :ok, %State{state | tests: 0}}
  end
  def handle_call(:errors, _from, state = %State{agent: agent}) do
    response = ErrAgent.errors(agent)
    {:reply, response, state}
  end
  def handle_call(_msg, _from, state) do
    {:reply, :unknown_msg, state}
  end

  @doc false
  def handle_info({:io_request, from, ref, 
                  {:put_chars, _encoding, :io_lib, :format, [msg, value_list]}}, state) do
    # Receive all IO requests here
    new_state = handle_output(msg, value_list, from, state)
    from |> send({:io_reply, ref, :ok})
    {:noreply, new_state}
  end
  def handle_info({:io_request, from, ref, 
                  {:put_chars, :io_lib, :format, [msg, value_list]}}, state) do
    # Receive all IO requests here
    new_state = handle_output(msg, value_list, from, state)
    from |> send({:io_reply, ref, :ok})
    {:noreply, new_state}
  end
  def handle_info({:io_request, from, ref, 
                  {:put_chars, _encoding, msg}}, state) do
    # Receive all IO requests here
    new_state = handle_output(msg, [], from, state)
    from |> send({:io_reply, ref, :ok})
    {:noreply, new_state}
  end
  def handle_info({:io_request, from, ref, 
                  {:put_chars, msg}}, state) do
    # Receive all IO requests here
    new_state = handle_output(msg, [], from, state)
    from |> send({:io_reply, ref, :ok})
    {:noreply, new_state}
  end
  def handle_info(_msg, state) do
    # Unsupported message -> discarded
    # This means reading input is impossible with this IOServer.
    {:noreply, state}   
  end

  # Helper functions

  @doc "Helper function to manipulate output."
  def handle_output('.', [], _from, state) do
    '.'
    |> colorize(:green, state.enabled)
    |> write(state)
    state
  end
  def handle_output('x', [], _from, state) do
    'x'
    |> colorize(:red, state.enabled)
    |> write(state)
    state
  end
  def handle_output('~nRan ~p tests~n', [amount], _from, state) do
    %State{state | tests: state.tests + amount - 1}
  end
  def handle_output('Testing ~p' ++ _rest, _value_list, _from, state) do
    # Filter this statement out, output shows up in ExUnit anyway
    # in case of failure
    state
  end
  def handle_output(msg = ('~nFailed' ++ _rest), value_list, from, state) do
    add_error_output(state, from, msg, value_list)
    state
  end
  def handle_output('Failed' ++ rest, value_list, from, state) do
    add_error_output(state, from, '~nFailed' ++ rest, value_list)  # fix formatting..
    state
  end
  def handle_output(msg = 'Simplified' ++ _rest, value_list, from, state) do
    add_error_output(state, from, msg, value_list)
    state
  end
  def handle_output(msg = '\t~s = ~w~n' ++ _rest, value_list, from, state) do
    add_error_output(state, from, msg, value_list)
    state
  end
  def handle_output(msg, value_list, _from, state) do
    # Fallback: simply forward messages to old group leader.
    :io.format(state.gl, msg, value_list)
    state
  end

  defp add_error_output(state, from, msg, value_list) do
    state.agent |> ErrAgent.add_error(from, {msg, value_list})
  end

  defp colorize(msg, color, enabled?) do
    [IO.ANSI.format_fragment(color, enabled?), 
      msg,
      IO.ANSI.format_fragment(:reset, enabled?)] |> IO.iodata_to_binary
  end

  defp write(msg, state) do
    IO.write state.gl, msg
  end
end
