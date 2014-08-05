defmodule ExCheck.Predicate do
  @moduledoc """
  Provides macros for predicates.
  """

  @doc """
  Verify the property is hold for all the generated samples.
    > for_all x in int, do: x * x >= 0
  """
  defmacro for_all({:in, _, [x, generator]}, [do: property]) do
    quote do
      { :"prop:forall", unquote(generator), unquote(stringify(x)),
        fn(unquote(x)) -> unquote(property) end, unquote(stringify(property)) }
    end
  end

  @doc """
  Verify the property is hold for all the generated samples.
    > for_all(x, int) do
    >   x * x >= 0
    > end
  """
  defmacro for_all(x, generator, [do: property]) do
    quote do
      { :"prop:forall", unquote(generator), unquote(stringify(x)),
        fn(unquote(x)) -> unquote(property) end, unquote(stringify(property)) }
    end
  end

  @doc """
  Skip samples that does not satisfy the predicate.
  """
  defmacro implies(predicate, [do: property]) do
    quote do
      { :"prop:implies", unquote(predicate), unquote(stringify(predicate)),
        fn() -> unquote(property) end, unquote(stringify(property)) }
    end
  end

  @doc """
  Specify the block to be called when the test is failed.
  """
  defmacro when_fail(action, [do: property]) do
    quote do
      { :"prop:whenfail", fn() -> unquote(action) end,
        fn() -> unquote(property) end, unquote(stringify(property)) }
    end
  end

  @doc """
  Specify the block to be executed with spawn_link
  """
  defmacro trap_exit([do: property]) do
    quote do
      { :"prop:trapexit", fn() -> unquote(property) end,
        unquote(stringify(property)) }
    end
  end

  @doc """
  Specify the block to be executed with timeout.
  """
  defmacro timeout(limit, [do: property]) do
    quote do
      { :"prop:timeout", unquote(limit),
        fn() -> unquote(property) end, unquote(stringify(property)) }
    end
  end


  @doc """
  Generate samples which satisfies the predicate.
  """
  defmacro such_that({:when, _, [{:in, _, [x, generator]}, predicate]}) do
    quote do
      :triq_dom.suchthat(
        unquote(generator), fn(unquote(x)) -> unquote(predicate) end)
    end
  end

  defp stringify(tree) do
    tree |> Macro.to_string |> String.to_char_list
  end
end
