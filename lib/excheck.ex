defmodule ExCheck do
  @moduledoc """
  Provides QuickCheck style testing feature.
  add 'use ExCheck' in the ExUnit test files.
  """

  @iterations Application.get_env(:excheck, :number_iterations, 100)

  defmacro __using__(_opts \\ []) do
    quote do
      import ExCheck.Predicate
      import ExCheck.Statement
      use ExCheck.Generator
    end
  end

  @doc """
  Check the property defined in the specified target (module or method).
  If the module name is specified, check all the methods prefixed with 'prop_'.
  """
  def check(target) do
    case :triq.check(target, @iterations) do
      true ->
        true
      false ->
        false
      {:EXIT, %{__struct__: ExUnit.AssertionError} = error} ->
        raise error
      {:EXIT, %{__struct__: type, message: msg}} ->
        raise %ExCheck.Error{message: "error raised: (#{type}) #{msg}"}
      error ->
        raise %ExCheck.Error{message: "check failed: #{inspect error}"}
    end
  end
end
