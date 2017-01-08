defmodule ExCheck.PredicateTest do
  use ExUnit.Case, async: false
  use ExCheck
  import ExUnit.CaptureIO

  property :implies do
    for_all x in int() do
      implies x >= 0 do
        x >= 0
      end
    end
  end

  property :such_that do
    for_all {x, y} in such_that({xx, yy} in {int(), int()} when xx < yy) do
      x < y
    end
  end

  def prop_always_fail do
    for_all x in int() do
      when_fail(:io.format("Failed value X = ~p", [x])) do
        false
      end
    end
  end

  def prop_sometimes_fail do
    for_all l in list(int()) do
      implies l != [] do
        for_all i in elements(l) do
          when_fail(:io.format("Failed value L = ~p, I = ~p~n", [l,i])) do
            :lists.member(i, :lists.delete(i, l)) == false
          end
        end
      end
    end
  end

  test "always fail property" do
    assert capture_io(fn ->
      ExCheck.check(prop_always_fail())
    end) =~ "Failed value X ="
  end

  test "sometimes fail property" do
    assert capture_io(fn ->
      ExCheck.check(prop_sometimes_fail())
    end) =~ "Failed value L ="
  end

  property :trapexit do
    for_all {xs, ys} in {list(int()), list(int())} do
      trap_exit do
        Enum.reverse(Enum.concat(xs, ys)) ==
          Enum.concat(Enum.reverse(ys), Enum.reverse(xs))
      end
    end
  end

  def prop_timeout do
    for_all x in oneof([50, 150]) do
      timeout(100) do
        :timer.sleep(x) == :ok
      end
    end
  end

  test "timeout fail property" do
    assert capture_io(fn ->
      assert_raise(ExCheck.Error, "check failed: {:EXIT, {:timeout, 100}}", fn ->
        ExCheck.check(prop_timeout())
      end)
    end) =~ "{'EXIT',{timeout,100}}"
  end

  defmodule SampleError do
    defexception message: nil
  end

  def prop_exception do
    for_all(_x, int()) do
      raise %SampleError{message: "sample message"}
    end
  end

  test "exception fail property" do
    assert capture_io(fn ->
      assert_raise(ExCheck.Error, "error raised: (Elixir.ExCheck.PredicateTest.SampleError) sample message", fn ->
        ExCheck.check(prop_exception())
      end)
    end) =~ "Elixir.ExCheck.PredicateTest.SampleError"
  end

  property :excpetion do
    for_all x in int() do
      try do
        abs(10 / x) <= 10
      rescue
        _e in ArithmeticError -> true
      end
    end
  end
end
