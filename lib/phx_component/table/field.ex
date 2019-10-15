defmodule PhxComponent.Table.Field do
  @moduledoc false

  alias Phoenix.HTML.Link

  defstruct key: nil, format: nil, attrs: [], link: nil, link_fun: &Link.link/2, title: nil

  def normalize(%{} = field, opts) do
    field =
      field
      |> normalize_key()
      |> normalize_attrs()

    field =
      case opts do
        %{link_fun: link_fun} when is_function(link_fun) ->
          Map.put_new(field, :link_fun, link_fun)

        _ ->
          field
      end

    struct(__MODULE__, field)
  end

  def normalize(field, opts) do
    normalize(%{key: field}, opts)
  end

  defp normalize_key(%{key: [_ | _]} = item), do: item
  defp normalize_key(%{key: key} = item), do: Map.put(item, :key, [key])
  defp normalize_key(item), do: item

  defp normalize_attrs(item) do
    Map.put_new_lazy(item, :attrs, fn ->
      item |> Map.drop([:key, :format, :link, :link_fun]) |> Keyword.new()
    end)
  end
end
