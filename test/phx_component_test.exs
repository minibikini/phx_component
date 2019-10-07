defmodule PhxComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.HTML

  doctest PhxComponent

  @items [
    %{id: 1, name: "foo"},
    %{id: 2, name: "bar"}
  ]

  test "table/2" do
    opts = [body: [:id, :name]]

    html = PhxComponent.table(@items, opts) |> safe_to_string()

    assert Floki.find(html, "table thead tr th") == [{"th", [], ["Id"]}, {"th", [], ["Name"]}]

    assert Floki.find(html, "table tbody tr td") == [
             {"td", [], ["1"]},
             {"td", [], ["foo"]},
             {"td", [], ["2"]},
             {"td", [], ["bar"]}
           ]
  end
end
