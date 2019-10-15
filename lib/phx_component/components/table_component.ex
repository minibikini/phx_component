defmodule PhxComponent.TableComponent do
  @moduledoc false
  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]
  import PhxComponent.Table.Utils

  alias PhxComponent.Table

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
    opts = if is_nil(opts[:head]), do: derive_head_from_fields(opts), else: opts

    struct(Table, opts)
  end

  defp normalize_option({:head, items}, _opts) do
    {:head, Enum.map(items, &Table.Th.normalize/1)}
  end

  defp normalize_option({:fields, items}, opts) do
    {:fields, Enum.map(items, &Table.Field.normalize(&1, opts))}
  end

  defp normalize_option(opt, _opts), do: opt

  defp derive_head_from_fields(opts) do
    head =
      opts[:fields]
      |> Enum.map(&get_title/1)
      |> Enum.map(&Table.Th.normalize/1)

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
    rows = Enum.map(items, &render_tr(&1, opts.fields)) ++ opts.body_extra
    content_tag(:tbody, rows, opts.tbody)
  end

  defp render_tr(item, fields) do
    content_tag(:tr, Enum.map(fields, &render_td(&1, item)))
  end

  defp render_td(field, item) do
    value = item |> get_value(field.key) |> format(field, item) |> maybe_link(field, item)
    content_tag(:td, value, attrs(value, item, field))
  end
end
