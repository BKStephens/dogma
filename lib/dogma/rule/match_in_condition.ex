use Dogma.RuleBuilder

defrule Dogma.Rule.MatchInCondition do
  @moduledoc ~S"""
  Disallows use of the match operator in the conditional constructs `if` and
  `unless`. This is because it is often intended to be `==` instead, but was
  mistyped. Also, since a failed match raises a MatchError, the conditional
  construct is largely redundant.

  The following would be invalid:

      if {x, y} = z do
        something
      end
  """

  def test(_rule, script) do
    script |> Script.walk( &check_ast(&1, &2) )
  end

  for fun <- [:if, :unless] do
    defp check_ast({unquote(fun), meta, [pred, [do: _]]} = ast, errors) do
      errors = if pred |> invalid? do
        [error(meta[:line]) | errors]
      else
        errors
      end
      {ast, errors}
    end
  end
  defp check_ast(ast, errors) do
    {ast, errors}
  end


  defp invalid?({:=, _, _}) do
    true
  end
  defp invalid?(_) do
    false
  end

  defp error(line) do
    %Error{
      rule:    __MODULE__,
      message: "Do not use = in if or unless.",
      line:    line,
    }
  end
end
