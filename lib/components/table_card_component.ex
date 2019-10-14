defmodule PhxComponent.TableCardComponent do
  @moduledoc false
  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]

  alias Phoenix.HTML.Link

  defmodule BodyItem do
    @moduledoc false
    defstruct key: nil, format: nil, attrs: [], link: nil, link_fun: &Link.link/2, title: nil
  end

  defstruct body: [],
            class: "",
            tbody: [],
            link_fun: &Link.link/2

  @default_class "table"

  def render(item, opts) do
    opts = normalize_options(opts)
    class = @default_class <> " " <> opts.class

    content_tag :table, class: class do
      tbody(item, opts)
    end
  end

  defp normalize_options(opts) do
    opts = Enum.map(opts, &normalize_option(&1, opts))

    struct(__MODULE__, opts)
  end

  defp normalize_option({:body, items}, opts) do
    {:body, Enum.map(items, &normalize_body_option(&1, opts))}
  end

  defp normalize_option(opt, _opts), do: opt

  defp normalize_body_option(%{} = item, opts) do
    item =
      item
      |> normalize_key()
      |> normalize_attrs()

    item =
      case opts do
        %{link_fun: link_fun} when is_function(link_fun) -> Map.put_new(item, :link_fun, link_fun)
        _ -> item
      end

    struct(BodyItem, item)
  end

  defp normalize_body_option(item, opts) do
    normalize_body_option(%{key: item}, opts)
  end

  defp normalize_key(%{key: [_ | _]} = item), do: item
  defp normalize_key(%{key: key} = item), do: Map.put(item, :key, [key])
  defp normalize_key(item), do: item

  defp normalize_attrs(item) do
    Map.put_new_lazy(item, :attrs, fn ->
      item |> Map.drop([:key, :format, :link, :link_fun]) |> Keyword.new()
    end)
  end

  defp tbody(item, opts) do
    rows = Enum.map(opts.body, &render_tr(item, &1))
    content_tag(:tbody, rows, opts.tbody)
  end

  defp render_tr(item, field) do
    content_tag :tr do
      [
        content_tag(:th, get_title(field)),
        render_td(field, item)
      ]
    end
  end

  defp get_title(field) do
    case field do
      %{title: title} when not is_nil(title) ->
        title

      %{key: nil} ->
        ""

      %{key: key} ->
        key
        |> List.last()
        |> to_string()
        |> String.split("_")
        |> Enum.map(&String.capitalize/1)
        |> Enum.join(" ")
    end
  end

  defp render_td(field, item) do
    value = item |> get_value(field.key) |> format(field, item) |> maybe_link(field, item)
    content_tag(:td, value, attrs(value, item, field))
  end

  defp maybe_link(value, %{link: nil} = _column, _item), do: value

  defp maybe_link(value, %{link_fun: fun, link: linker} = column, item) do
    fun.(value, linker.(value, item, column))
  end

  defp attrs(value, item, column) do
    Enum.map(column.attrs, &attrs(&1, value, item, column))
  end

  defp attrs({name, fun}, field_value, item, column) when is_function(fun) do
    value =
      cond do
        is_function(fun, 1) -> fun.(field_value)
        is_function(fun, 2) -> fun.(field_value, item)
        is_function(fun, 3) -> fun.(field_value, item, column)
      end

    {name, value}
  end

  defp attrs(attr, _field_value, _item, _column), do: attr

  defp get_value(map, [key | tail]) when is_map(map) do
    get_value(Map.get(map, key), tail)
  end

  defp get_value(nil, _), do: nil

  defp get_value(list, [idx | tail]) when is_list(list) do
    get_value(Enum.at(list, idx), tail)
  end

  defp get_value(value, []), do: value
  defp get_value(_value, nil), do: nil

  defp format(value, %{format: nil}, _item), do: value

  defp format(value, %{format: format} = column, item) do
    cond do
      is_function(format, 1) -> format.(value)
      is_function(format, 2) -> format.(value, item)
      is_function(format, 3) -> format.(value, item, column)
    end
  end
end
