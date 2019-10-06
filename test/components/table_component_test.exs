defmodule TableComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.HTML

  alias PhxComponent.TableComponent

  @items [
    %{id: 1, name: "foo"},
    %{id: 2, name: "bar"}
  ]

  describe "link attribute" do
    test "default link function" do
      opts = %{
        body: [
          :id,
          %{key: :name, link: fn _value, item, _column -> [to: "/users/#{item.id}"] end}
        ]
      }

      assert safe_to_string(TableComponent.render(@items, opts)) ==
               "<table class=\"table \"><thead class=\"thead-dark\"><tr><th>Id</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td><a href=\"/users/1\">foo</a></td></tr><tr><td>2</td><td><a href=\"/users/2\">bar</a></td></tr></tbody></table>"
    end

    test "custom link function" do
      link_fun = fn value, attrs ->
        raw(~s(<a href="http://x.com#{attrs[:to]}">#{value}</a>))
      end

      opts = %{
        link_fun: link_fun,
        body: [
          :id,
          %{
            key: :name,
            link: fn _value, item, _column -> [to: "/u/#{item.id}"] end
          }
        ]
      }

      assert safe_to_string(TableComponent.render(@items, opts)) ==
               "<table class=\"table \"><thead class=\"thead-dark\"><tr><th>Id</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td><a href=\"http://x.com/u/1\">foo</a></td></tr><tr><td>2</td><td><a href=\"http://x.com/u/2\">bar</a></td></tr></tbody></table>"
    end

    test "custom row link function" do
      link_fun = fn value, attrs ->
        raw(~s(<a href="http://x.com#{attrs[:to]}">#{value}</a>))
      end

      opts = %{
        body: [
          :id,
          %{
            key: :name,
            link_fun: link_fun,
            link: fn _value, item, _column -> [to: "/u/#{item.id}"] end
          }
        ]
      }

      assert safe_to_string(TableComponent.render(@items, opts)) ==
               "<table class=\"table \"><thead class=\"thead-dark\"><tr><th>Id</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td><a href=\"http://x.com/u/1\">foo</a></td></tr><tr><td>2</td><td><a href=\"http://x.com/u/2\">bar</a></td></tr></tbody></table>"
    end

    test "custom row link function is more important than global custom link" do
      link_fun = fn value, attrs ->
        raw(~s(<a href="http://x.com#{attrs[:to]}">#{value}</a>))
      end

      opts = %{
        link_fun: fn _value, _attrs -> "42" end,
        body: [
          :id,
          %{
            key: :name,
            link_fun: link_fun,
            link: fn _value, item, _column -> [to: "/u/#{item.id}"] end
          }
        ]
      }

      assert safe_to_string(TableComponent.render(@items, opts)) ==
               "<table class=\"table \"><thead class=\"thead-dark\"><tr><th>Id</th><th>Name</th></tr></thead><tbody><tr><td>1</td><td><a href=\"http://x.com/u/1\">foo</a></td></tr><tr><td>2</td><td><a href=\"http://x.com/u/2\">bar</a></td></tr></tbody></table>"
    end
  end
end
