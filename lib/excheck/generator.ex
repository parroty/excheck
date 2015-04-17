defmodule ExCheck.Generator do
  @moduledoc """
  Provides macros for generators.
  """

  defmacro __using__(_opts \\ []) do
    quote do
      # Import generators defined in :triq minus redefined ones.
      import :triq_dom, except: [atom: 0], only: :functions
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

  @doc """
  Generates atom, including the special ones :nil, :false and :true.
  """
  defmacro atom do
    quote do
      oneof([:triq_dom.atom(), oneof([bool(), :nil])])
    end
  end
end
