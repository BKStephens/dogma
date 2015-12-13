defmodule Dogma.Rule.ModuleDocTest do
  use ShouldI

  alias Dogma.Rule.ModuleDoc
  alias Dogma.Script
  alias Dogma.Error

  defp lint(script) do
    script |> Script.parse!( "foo.ex" ) |> ModuleDoc.test
  end


  with "module docs" do
    should "not error" do
      errors = """
      defmodule VeryGood do
        @moduledoc "Lots of good info here"
      end
      """ |> lint
      assert [] == errors
    end

    should "not error with nested modules" do
      errors = """
      defmodule VeryGood do
        @moduledoc "Lots of good info here"
        defmodule AlsoGood do
          @moduledoc "And even more here!"
        end
      end
      """ |> lint
      assert [] == errors
    end
  end

  should "error for a module missing a module doc" do
    errors = """
    defmodule NotGood do
    end
    """ |> lint
    expected_errors = [
      %Error{
        rule: ModuleDoc,
        message: "Module NotGood is missing a @moduledoc.",
        line: 1,
      }
    ]
    assert expected_errors == errors
  end

  should "print the module name in the error message" do
    module_name = "ModName"
    source = """
    defmodule #{module_name} do
    end
    """
    error = source |> lint |> List.first
    assert error.message |> String.contains?(module_name)
  end

  should "print the module name correctly when it is namespaced" do
    module_name = "Namespace.ModName"
    source = """
    defmodule #{module_name} do
    end
    """
    error = source |> lint |> List.first
    assert error.message |> String.contains?(module_name)
  end

  should "error for a nested module missing a module doc" do
    errors = """
    defmodule VeryGood do
      @moduledoc "Lots of good info here"
      defmodule NotGood do
      end
    end
    """ |> lint
    expected_errors = [
      %Error{
        rule: ModuleDoc,
        message: "Module NotGood is missing a @moduledoc.",
        line: 3,
      }
    ]
    assert expected_errors == errors
  end

  should "error for a parent module missing a module doc" do
    errors = """
    defmodule NotGood do
      defmodule VeryGood do
        @moduledoc "Lots of good info here"
      end
    end
    """ |> lint
    expected_errors = [
      %Error{
        rule: ModuleDoc,
        message: "Module NotGood is missing a @moduledoc.",
        line: 1,
      }
    ]
    assert expected_errors == errors
  end

  should "not error for an exs file (exs is skipped)" do
    errors = """
    defmodule NotGood do
    end
    """ |> Script.parse!( "foo.exs" ) |> ModuleDoc.test
    assert [] == errors
  end

  should "not crash for unquoted module names" do
    errors = """
    quote do
      defmodule unquote(name) do
      end
    end
    """ |> lint
    assert errors == [
      %Error{
        rule: ModuleDoc,
        message: "Unknown module is missing a @moduledoc.",
        line: 2,
      }
    ]
  end
end
