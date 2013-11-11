defmodule ExCheck.Statement do
  @moduledoc """
  Provides macros for test statements.
  """

  @doc """
  Generate property method and ExUnit tests
  """
  defmacro property(message, [do: contents]) do
    contents = Macro.escape(contents, unquote: true)
    quote bind_quoted: binding do
      def unquote(:"prop_#{message}")(), do: unquote(contents)
      test :"#{message}_property" do
        assert :triq.check(unquote(:"prop_#{message}")())
      end
    end
  end

  @doc """
  Test the property methods defined in the specified module.
  The name of the methods need to be prefixed with 'prop_'.
  """
  def check(module) do
    :triq.check(module)
  end
end
