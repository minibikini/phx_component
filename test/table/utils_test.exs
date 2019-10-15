defmodule PhxComponent.Table.UtilsTest do
  use ExUnit.Case, async: true

  alias PhxComponent.Table.Utils

  describe "get_value/2" do
    test "can be string/atom " do
      assert Utils.get_value(%{id: 1}, [:id]) == 1
    end

    test "can be string" do
      assert Utils.get_value(%{"id" => 1}, ["id"]) == 1
    end

    test "can be a list index" do
      assert Utils.get_value(["one", "two", "three"], [1]) == "two"
    end

    test "can be nested" do
      item = %{
        "one" => %{two: %{"three" => "four"}},
        a: ["one", %{data: "two"}, "three"]
      }

      assert Utils.get_value(item, ["one", :two, "three"])
      assert Utils.get_value(item, [:a, 1, :data])
    end
  end
end
