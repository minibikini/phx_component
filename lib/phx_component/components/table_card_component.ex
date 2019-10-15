defmodule PhxComponent.TableCardComponent do
  @moduledoc false
  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]
  import PhxComponent.Table.Utils

  alias PhxComponent.Table

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

    struct(Table, opts)
  end

  defp normalize_option({:fields, items}, opts) do
    {:fields, Enum.map(items, &Table.Field.normalize(&1, opts))}
  end

  defp normalize_option(opt, _opts), do: opt

  defp tbody(item, opts) do
    rows = Enum.map(opts.fields, &render_tr(item, &1))
    content_tag(:tbody, rows, opts.tbody)
  end

  defp render_tr(item, field) do
    content_tag :tr do
      [
        content_tag(:th, get_title(field), style: "white-space:nowrap;"),
        render_td(field, item)
      ]
    end
  end

  defp render_td(field, item) do
    value = item |> get_value(field.key) |> format(field, item) |> maybe_link(field, item)
    attrs = attrs(value, item, field) ++ [style: "width:100%;"]

    content_tag(:td, value, attrs)
  end
end
