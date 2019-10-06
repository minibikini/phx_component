defmodule PhxComponent.TableComponent do
  @moduledoc false
  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]

  alias Phoenix.HTML.Link

  defmodule HeadItem do
    @moduledoc false
    defstruct value: nil, class: nil
  end

  defmodule BodyItem do
    @moduledoc false
    defstruct key: nil, format: nil, attrs: [], link: nil, link_fun: &Link.link/2
  end

  defstruct head: [],
            body: [],
            class: "",
            body_extra: [],
            thead: [class: "thead-dark"],
            tbody: [],
            link_fun: &Link.link/2

  @default_class "table"

  def render(collection, opts) do
    opts = normalize_options(opts)
    class = @default_class <> " " <> opts.class

    content_tag :table, class: class do
      [thead(opts), tbody(collection, opts)]
    end
  end

  defp normalize_options(opts) do
    opts = Enum.map(opts, &normalize_option(&1, opts))
    opts = if is_nil(opts[:head]), do: derive_head_from_body(opts), else: opts

    struct(__MODULE__, opts)
  end

  defp normalize_option({:head, items}, _opts) do
    {:head, Enum.map(items, &normalize_header_option/1)}
  end

  defp normalize_option({:body, items}, opts) do
    {:body, Enum.map(items, &normalize_body_option(&1, opts))}
  end

  defp normalize_option(opt, _opts), do: opt

  defp normalize_header_option(%{} = item) do
    struct(HeadItem, item)
  end

  defp normalize_header_option(item) when is_binary(item) do
    normalize_header_option(%{value: item})
  end

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

  defp derive_head_from_body(opts) do
    head =
      Enum.map(opts[:body], fn
        %{key: nil} ->
          normalize_header_option(%{value: nil})

        %{key: key} ->
          key
          |> List.last()
          |> to_string()
          |> String.split("_")
          |> Enum.map(&String.capitalize/1)
          |> Enum.join(" ")
          |> normalize_header_option()
      end)

    if Enum.any?(head, fn h -> not is_nil(h.value) end) do
      Keyword.put(opts, :head, head)
    else
      opts
    end
  end

  defp thead(%{head: []}), do: ""

  defp thead(%{head: items, thead: attrs}) do
    content_tag :thead, attrs do
      content_tag(:tr, Enum.map(items, &content_tag(:th, &1.value, class: &1.class)))
    end
  end

  defp tbody(items, opts) do
    rows = Enum.map(items, &render_tr(&1, opts.body)) ++ opts.body_extra
    content_tag(:tbody, rows, opts.tbody)
  end

  defp render_tr(item, columns) do
    content_tag(:tr, Enum.map(columns, &render_td(&1, item)))
  end

  defp render_td(column, item) do
    value = item |> get_value(column.key) |> format(column, item) |> maybe_link(column, item)
    content_tag(:td, value, attrs(value, item, column))
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

  defp get_value(map, [key | tail]) do
    get_value(Map.get(map, key), tail)
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
