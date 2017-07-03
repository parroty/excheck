defmodule ExCheck do
  use Application

  @moduledoc """
  Provides QuickCheck style testing feature.
  add 'use ExCheck' in the ExUnit test files.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      import ExCheck.Predicate
      import ExCheck.Statement
      use ExCheck.Generator
      use ExUnit.Callbacks

      setup(context) do
        {:ok, context}
      end
    end
  end

  @doc "Starts the ExCheck application."
  def start do
    {:ok, :triq_rnd} = :triq_rand_compat.init('triq_rnd')
    ExUnit.configure(formatters: [ExCheck.Formatter])
    Application.ensure_all_started(:excheck)
  end

  @doc "Starts the ExCheck application."
  def start(_app, _type) do
    import Supervisor.Spec, warn: false
    children = [
      worker(ExCheck.TriqAgent, [])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @doc """
  Check the property defined in the specified target (module or method).
  If the module name is specified, check all the methods prefixed with 'prop_'.
  """
  def check(target, iterations \\ nil) do
    default_iterations = Application.get_env(:excheck, :number_iterations, 100)
    case :triq.check(target, iterations || default_iterations) do
      true ->
        :ok
      false ->
        example = :triq.counterexample()
        {:error, %ExCheck.Error{message: "check failed: Counterexample: #{inspect example}"}}
      {:EXIT, %{__struct__: _, message: _} = e} ->
        example = :triq.counterexample()
        {:error, e}
      error ->
        example = :triq.counterexample()
        {:error, %ExCheck.Error{message: "check failed: #{inspect error}. Counterexample: #{inspect example}"}}
    end
  end

  def check!(target, iterations \\ nil) do
    case check(target, iterations) do
      :ok -> :ok
      {:error, e} -> raise e
    end
  end
end
