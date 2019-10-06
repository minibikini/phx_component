defmodule TableComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.HTML

  @items [
    %{id: 1, name: "foo"},
    %{id: 2, name: "bar"}
  ]

  defp render(items, opts),
    do: items |> PhxComponent.TableComponent.render(opts) |> safe_to_string()

  test "table/2" do
    opts = [body: [:id, :name]]

    html = render(@items, opts)

    assert Floki.find(html, "table thead tr") == [
             {"tr", [], [{"th", [], ["Id"]}, {"th", [], ["Name"]}]}
           ]

    assert Floki.find(html, "table tbody tr") == [
             {"tr", [], [{"td", [], ["1"]}, {"td", [], ["foo"]}]},
             {"tr", [], [{"td", [], ["2"]}, {"td", [], ["bar"]}]}
           ]
  end

  describe "link attribute" do
    test "default link function" do
      opts = %{
        body: [
          :id,
          %{key: :name, link: fn _value, item, _column -> [to: "/users/#{item.id}"] end}
        ]
      }

      assert @items |> render(opts) |> Floki.find("table tbody tr td a") == [
               {"a", [{"href", "/users/1"}], ["foo"]},
               {"a", [{"href", "/users/2"}], ["bar"]}
             ]
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

      assert @items |> render(opts) |> Floki.find("table tbody tr td a") == [
               {"a", [{"href", "http://x.com/u/1"}], ["foo"]},
               {"a", [{"href", "http://x.com/u/2"}], ["bar"]}
             ]
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

      assert @items |> render(opts) |> Floki.find("table tbody tr td a") == [
               {"a", [{"href", "http://x.com/u/1"}], ["foo"]},
               {"a", [{"href", "http://x.com/u/2"}], ["bar"]}
             ]
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

      assert @items |> render(opts) |> Floki.find("table tbody tr td a") == [
               {"a", [{"href", "http://x.com/u/1"}], ["foo"]},
               {"a", [{"href", "http://x.com/u/2"}], ["bar"]}
             ]
    end
  end
end
