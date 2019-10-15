defmodule PhxComponent.Table.Utils do
  @moduledoc false

  def format(value, %{format: nil}, _item), do: value

  def format(value, %{format: format} = field, item) do
    cond do
      is_function(format, 1) -> format.(value)
      is_function(format, 2) -> format.(value, item)
      is_function(format, 3) -> format.(value, item, field)
    end
  end

  def get_value(map, [key | tail]) when is_map(map) do
    get_value(Map.get(map, key), tail)
  end

  def get_value(list, [idx | tail]) when is_list(list) do
    get_value(Enum.at(list, idx), tail)
  end

  def get_value(nil, _), do: nil
  def get_value(value, []), do: value
  def get_value(_value, nil), do: nil

  def attrs(value, item, field) do
    Enum.map(field.attrs, &attrs(&1, value, item, field))
  end

  def attrs({name, fun}, field_value, item, field) when is_function(fun) do
    value =
      cond do
        is_function(fun, 1) -> fun.(field_value)
        is_function(fun, 2) -> fun.(field_value, item)
        is_function(fun, 3) -> fun.(field_value, item, field)
      end

    {name, value}
  end

  def attrs(attr, _field_value, _item, _field), do: attr

  def maybe_link(value, %{link: nil} = _field, _item), do: value

  def maybe_link(value, %{link_fun: fun, link: linker} = field, item) do
    fun.(value, linker.(value, item, field))
  end

  def get_title(field) do
    case field do
      %{title: title} when not is_nil(title) ->
        title

      %{key: nil} ->
        nil

      %{key: key} ->
        key
        |> List.last()
        |> to_string()
        |> String.split("_")
        |> Enum.map(&String.capitalize/1)
        |> Enum.join(" ")
    end
  end
end
