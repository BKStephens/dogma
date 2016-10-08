defmodule Dogma.Util.CyclomaticComplexityTest do
  use ExUnit.Case, async: true

  alias Dogma.Util.CyclomaticComplexity

  defmacro complexity_of(do: code) do
    code |> CyclomaticComplexity.count
  end

  describe "an empty AST" do
    test "be 1" do
      size = complexity_of do end
      assert 1 == size
    end
  end

  test "register if" do
    size = complexity_of do
      if foo do
        bar
      end
    end
    assert 2 == size
  end

  test "register unless" do
    size = complexity_of do
      unless foo do
        bar
      end
    end
    assert 2 == size
  end

  test "register case" do
    size = complexity_of do
      case foo do
        1 -> :one
        _ -> :not_one
      end
    end
    assert 2 == size
  end

  test "register cond" do
    size = complexity_of do
      cond do
        foo == 1 -> :one
        true     -> :not_one
      end
    end
    assert 2 == size
  end

  test "register &&" do
    size = complexity_of do
      1 && 2
    end
    assert 2 == size
  end

  test "register and" do
    size = complexity_of do
      1 and 2
    end
    assert 2 == size
  end

  test "register ||" do
    size = complexity_of do
      1 || 2
    end
    assert 2 == size
  end

  test "register or" do
    size = complexity_of do
      1 or 2
    end
    assert 2 == size
  end
end
