defmodule PhxComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.HTML

  doctest PhxComponent

  @items [
    %{id: 1, name: "foo"},
    %{id: 2, name: "bar"}
  ]

  test "table/2" do
    opts = [fields: [:id, :name]]

    html = PhxComponent.table(@items, opts) |> safe_to_string()

    assert Floki.find(html, "table thead tr th") == [{"th", [], ["Id"]}, {"th", [], ["Name"]}]

    assert Floki.find(html, "table tbody tr") == [
             {"tr", [], [{"td", [], ["1"]}, {"td", [], ["foo"]}]},
             {"tr", [], [{"td", [], ["2"]}, {"td", [], ["bar"]}]}
           ]
  end

  test "table_card/2" do
    opts = [fields: [:id, %{key: :name}], class: "my-table"]

    html = PhxComponent.table_card(hd(@items), opts) |> safe_to_string()

    assert Floki.find(html, "table thead") == []

    assert Floki.find(html, "table.my-table tbody tr") == [
             {"tr", [],
              [
                {"th", [{"style", "white-space:nowrap;"}], ["Id"]},
                {"td", [{"style", "width:100%;"}], ["1"]}
              ]},
             {"tr", [],
              [
                {"th", [{"style", "white-space:nowrap;"}], ["Name"]},
                {"td", [{"style", "width:100%;"}], ["foo"]}
              ]}
           ]
  end
end
