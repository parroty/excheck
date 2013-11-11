defmodule ExCheck do
  @moduledoc """
  Provides QuickCheck style testing feature.
  add 'use ExCheck' in the ExUnit test files.
  """

  defmacro __using__(_opts // []) do
    quote do
      import ExCheck.Predicate
      import ExCheck.Statement
      import :triq_dom, only: :functions  # Import generators defined in :triq
    end
  end
end
