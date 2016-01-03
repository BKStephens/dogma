defmodule Dogma.Rule.MatchInConditionTest do
  use ShouldI

  alias Dogma.Rule.MatchInCondition
  alias Dogma.Script
  alias Dogma.Error

  defp lint(script) do
    script |> Script.parse!( "foo.ex" ) |> MatchInCondition.test
  end

  having "a variable/function argument" do
    should "not error for if" do
      errors = """
      if feeling_tired do
        have_an_early_night
      end
      """ |> lint
      assert [] == errors
    end

    should "not error for unless" do
      errors = """
      unless feeling_sleepy do
        a_little_dance
      end
      """ |> lint
      assert [] == errors
    end
  end

  having "a literal argument" do
    should "not error for if" do
      errors = """
      if false do
        i_will_never_run
      end
      """ |> lint
      assert [] == errors
    end

    should "not error for unless" do
      errors = """
      unless [] do
        useless_unless
      end
      """ |> lint
      assert [] == errors
    end
  end

  having "a piped in argument" do
    should "not error for if" do
      errors = """
      something
      |> if do
        something_else
      end
      """ |> lint
      assert [] == errors
    end

    should "not error for unless" do
      errors = """
      something
      |> unless do
        something_else
      end
      """ |> lint
      assert [] == errors
    end
  end

  having "a comparison argument" do
    should "not error for if" do
      errors = """
      if x ==  y do z end
      if x === y do z end
      if x !=  y do z end
      if x !== y do z end
      """ |> lint
      assert [] == errors
    end

    should "not error for unless" do
      errors = """
      unless x ==  y do z end
      unless x === y do z end
      unless x !=  y do z end
      unless x !== y do z end
      """ |> lint
      assert [] == errors
    end
  end

  having "match argument" do
    should "error for if" do
      errors = """
      if x         = y do z end
      if {x1, x2}  = y do z end
      if [x, _, _] = y do z end
      if %{ x: x } = y do z end
      """ |> lint
      expected_errors = [
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 4,
        },
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 3,
        },
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 2,
        },
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 1,
        },
      ]
      assert expected_errors == errors
    end

    should "error for unless" do
      errors = """
      unless x         = y do z end
      unless {x1, x2}  = y do z end
      unless [x, _, _] = y do z end
      unless %{ x: x } = y do z end
      """ |> lint
      expected_errors = [
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 4,
        },
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 3,
        },
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 2,
        },
        %Error{
          rule:    MatchInCondition,
          message: "Do not use = in if or unless.",
          line: 1,
        },
      ]
      assert expected_errors == errors
    end
  end
end
