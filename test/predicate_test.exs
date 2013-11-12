defmodule ExCheck.PredicateTest do
  use ExUnit.Case, async: false
  use ExCheck
  import ExUnit.CaptureIO

  property :implies do
    for_all(x, int) do
      implies(x >= 0) do
        x >= 0
      end
    end
  end

  property :such_that do
    for_all({x, y}, such_that({xx, yy}, {int, int}, xx < yy)) do
      x < y
    end
  end

  def prop_always_fail do
    for_all({x}, {int}) do
      when_fail(:io.format("Failed value X = ~p", [x])) do
        false
      end
    end
  end

  def prop_sometimes_fail do
    for_all({l}, {list(int)}) do
      implies(l != []) do
        for_all({i}, {elements(l)}) do
          when_fail(:io.format("Failed value L = ~p, I = ~p~n", [l,i])) do
            :lists.member(i, :lists.delete(i, l)) == false
          end
        end
      end
    end
  end

  test "always fail property" do
    assert capture_io(fn ->
      ExCheck.Statement.check(prop_always_fail)
    end) =~ "Failed value X ="
  end

  test "sometimes fail property" do
    assert capture_io(fn ->
      ExCheck.Statement.check(prop_sometimes_fail)
    end) =~ "Failed value L ="
  end

  property :trapexit do
    for_all({xs, ys}, {list(int), list(int)}) do
      trap_exit do
        Enum.reverse(Enum.concat(xs, ys)) ==
          Enum.concat(Enum.reverse(ys), Enum.reverse(xs))
      end
    end
  end

  def prop_timeout do
    for_all(x, oneof([50, 150])) do
      timeout(100) do
        :timer.sleep(x) == :ok
      end
    end
  end

  test "timeout fail property" do
    assert capture_io(fn ->
      ExCheck.Statement.check(prop_timeout)
    end) =~ "Failed with: {timeout,100}"
  end
end
