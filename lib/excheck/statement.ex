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
  Check the property defined in the specified target (module or method).
  If the module name is specified, check all the methods prefixed with 'prop_'.
  """
  def check(target) do
    :triq.check(target)
  end
end
