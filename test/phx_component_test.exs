defmodule PhxComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.HTML
  doctest PhxComponent

  test "table/2" do
    items = [
      %{id: 1, name: "foo"},
      %{id: 2, name: "bar"}
    ]

    assert safe_to_string(PhxComponent.table(items, body: [:id, :name])) ==
             "<table class=\"table \"><thead class=\"thead-dark\"><tr><th>Id</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td>foo</td></tr><tr><td>2</td><td>bar</td></tr></tbody></table>"
  end
end
