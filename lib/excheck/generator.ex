defmodule ExCheck.Generator do
  @moduledoc """
  Provides macros for generators.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      import :triq_dom, only: :functions  # Import generators defined in :triq.
      import ExCheck.Generator
    end
  end

  @doc """
  Generates number, which is either integer or real number.
  """
  defmacro number do
    quote do
      oneof([int(), real()])
    end
  end
end
