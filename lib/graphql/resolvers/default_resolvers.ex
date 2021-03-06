defmodule SlackCoder.GraphQL.Resolvers.DefaultResolvers do
  defmacro as(field) when is_atom(field) do
    quote do
      fn
        _, %{source: source} when is_map(source) -> {:ok, Map.get(source, unquote(field))}
        _, _ -> nil
      end
    end
  end

  defmacro as(function) do
    quote do
      fn
        _, %{source: source} when is_map(source) -> {:ok, unquote(function).(source)}
        _, _ -> nil
      end
    end
  end

  def force_boolean(field) do
    fn _, %{source: data} -> {:ok, !!Map.get(data, field)} end
  end
end
