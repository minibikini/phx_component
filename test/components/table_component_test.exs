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
    opts = [fields: [:id, :name]]

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
        fields: [
          :id,
          %{key: :name, link: fn _value, item, _field -> [to: "/users/#{item.id}"] end}
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
        fields: [
          :id,
          %{
            key: :name,
            link: fn _value, item, _field -> [to: "/u/#{item.id}"] end
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
        fields: [
          :id,
          %{
            key: :name,
            link_fun: link_fun,
            link: fn _value, item, _field -> [to: "/u/#{item.id}"] end
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
        fields: [
          :id,
          %{
            key: :name,
            link_fun: link_fun,
            link: fn _value, item, _field -> [to: "/u/#{item.id}"] end
          }
        ]
      }

      assert @items |> render(opts) |> Floki.find("table tbody tr td a") == [
               {"a", [{"href", "http://x.com/u/1"}], ["foo"]},
               {"a", [{"href", "http://x.com/u/2"}], ["bar"]}
             ]
    end
  end

  describe "table header" do
    test "disable header" do
      opts = [head: [], fields: [:id, :name]]

      html = render(@items, opts)

      assert Floki.find(html, "table thead") == []
    end

    test "empty header for a field when no :key" do
      opts = [fields: [:id, %{class: "x"}]]

      html = render(@items, opts)

      assert Floki.find(html, "table thead tr th") == [{"th", [], ["Id"]}, {"th", [], []}]

      opts = [fields: [%{class: "x"}]]

      html = render(@items, opts)

      assert Floki.find(html, "table thead") == []
    end

    test "derive from keys by default" do
      opts = [fields: [:id, :name]]

      html = render(@items, opts)

      assert Floki.find(html, "table thead tr th") == [{"th", [], ["Id"]}, {"th", [], ["Name"]}]
    end

    test "from head option" do
      opts = [
        head: ["ID", "NAME"],
        fields: [:id, :name]
      ]

      html = render(@items, opts)

      assert Floki.find(html, "table thead tr th") == [{"th", [], ["ID"]}, {"th", [], ["NAME"]}]
    end

    test "from title attibute" do
      opts = [
        fields: [:id, %{key: :name, title: "NAME"}]
      ]

      html = render(@items, opts)

      assert Floki.find(html, "table thead tr th") == [{"th", [], ["Id"]}, {"th", [], ["NAME"]}]
    end

    test "head is more important than title attibute" do
      opts = [
        head: ["ID", "NAME"],
        fields: [:id, %{key: :name, title: "_NAME"}]
      ]

      html = render(@items, opts)

      assert Floki.find(html, "table thead tr th") == [{"th", [], ["ID"]}, {"th", [], ["NAME"]}]
    end
  end

  describe "resource keys" do
    test "can be string/atom in resource list " do
      opts = [
        fields: [:id]
      ]

      html = render(@items, opts)

      assert Floki.find(html, "table tbody tr") == [
               {"tr", [], [{"td", [], ["1"]}]},
               {"tr", [], [{"td", [], ["2"]}]}
             ]
    end

    test "can be value of map in resource list " do
      opts = [
        fields: [%{key: :id}]
      ]

      html = render(@items, opts)

      assert Floki.find(html, "table tbody tr") == [
               {"tr", [], [{"td", [], ["1"]}]},
               {"tr", [], [{"td", [], ["2"]}]}
             ]
    end

    test "can be nested" do
      items = [
        %{
          "one" => %{two: %{"three" => "four"}},
          a: %{
            b: %{c: "ddd"}
          }
        }
      ]

      opts = [
        fields: [["one", :two, "three"], %{key: [:a, :b, :c]}]
      ]

      html = render(items, opts)

      assert Floki.find(html, "table tbody tr td") == [{"td", [], ["four"]}, {"td", [], ["ddd"]}]
    end
  end

  describe "format attribute" do
    result =
      [
        fn value -> value * 2 end,
        fn _value, item -> item.name end,
        fn _value, _item, field -> field.key |> hd() |> to_string() end
      ]
      |> Enum.map(fn format ->
        opts = [fields: [%{key: :id, format: format}]]
        # render(@items, opts)
        @items
        |> PhxComponent.TableComponent.render(opts)
        |> safe_to_string()
        |> Floki.find("table tbody tr td")
      end)

    assert result == [
             [{"td", [], ["2"]}, {"td", [], ["4"]}],
             [{"td", [], ["foo"]}, {"td", [], ["bar"]}],
             [{"td", [], ["id"]}, {"td", [], ["id"]}]
           ]
  end

  describe "custom attributes" do
    test "attributes" do
      opts = [
        fields: [%{key: :name, class: "cls", data_x: "y", cofe: "fe"}]
      ]

      html = render(@items, opts)

      assert Floki.find(html, "table tbody tr td") == [
               {"td", [{"class", "cls"}, {"cofe", "fe"}, {"data-x", "y"}], ["foo"]},
               {"td", [{"class", "cls"}, {"cofe", "fe"}, {"data-x", "y"}], ["bar"]}
             ]
    end

    test "attribute formatter" do
      result =
        [
          fn _value -> "one" end,
          fn _value, _item -> "two" end,
          fn _value, _item, _field -> "three" end
        ]
        |> Enum.map(fn format ->
          opts = [fields: [%{key: :id, class: format}]]
          # render(@items, opts)
          @items
          |> PhxComponent.TableComponent.render(opts)
          |> safe_to_string()
          |> Floki.find("table tbody tr td")
        end)

      assert result == [
               [{"td", [{"class", "one"}], ["1"]}, {"td", [{"class", "one"}], ["2"]}],
               [{"td", [{"class", "two"}], ["1"]}, {"td", [{"class", "two"}], ["2"]}],
               [{"td", [{"class", "three"}], ["1"]}, {"td", [{"class", "three"}], ["2"]}]
             ]
    end
  end
end
