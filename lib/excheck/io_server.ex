defmodule ExCheck.IOServer do
  use GenServer
  alias __MODULE__, as: State

  @moduledoc """
  Process which manipulates IO output and forwards it to previous group leader.
  """

  defstruct gl: :no_pid,    # Previous group leader process
            pids: [],       # The pids from which we are redirecting output
            tests: 0,       # Amount of triq property tests ran
            enabled: false  # Colors enabled in terminal?

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
    @server |> GenServer.call {:redirect, pid}
  end

  # Callbacks

  @doc false
  def init(:ok) do
    gl = Process.group_leader        # get previous group leader
    {:ok, %State{gl: gl, enabled: IO.ANSI.enabled?}}
  end

  @doc false
  def terminate(_reason, %State{gl: gl, pids: pids}) do
    for pid <- pids do
      Process.group_leader(pid, gl)  # Revert back to old group leader
    end
    :ok
  end

  @doc false
  def handle_call({:redirect, pid}, _from, state = %State{pids: pids}) do
    Process.group_leader(pid, self)  # redirect all IO from pid to this process
    {:reply, :ok, %State{state | pids: [pid | pids]}}
  end

  @doc false
  def handle_info({:io_request, from, ref, 
                  {:put_chars, :unicode, :io_lib, :format, [msg, value_list]}}, state) do
    # Receive all IO requests here
    new_state = handle_output(msg, value_list, state)
    from |> send {:io_reply, ref, :ok}
    {:noreply, new_state}
  end
  def handle_info({:io_request, from, ref, 
                  {:put_chars, :unicode, msg}}, state) do
    # Receive all IO requests here
    new_state = handle_output(msg, [], state)
    from |> send {:io_reply, ref, :ok}
    {:noreply, new_state}
  end

  # Helper functions

  @doc "Helper function to manipulate output."
  def handle_output('.', [], state) do
    '.'
    |> colorize(:green, state.enabled)
    |> write(state)
    state
  end
  def handle_output('x', [], state) do
    'x'
    |> colorize(:red, state.enabled)
    |> write(state)
    state
  end
  def handle_output(msg = '~nRan ~p tests~n', value_list = [amount], state) do
    :io.format(state.gl, msg, value_list)
    %State{state | tests: state.tests + amount}# TODO figure out way to print total at end..
  end 
  def handle_output(msg, value_list, state) do
    # Fallback: simply forward messages to old group leader.
    :io.format(state.gl, msg, value_list)
    state
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
