defmodule ExCheck.PredicateTest do
  use ExUnit.Case, async: false
  use ExCheck
  import ExUnit.CaptureIO

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
end
