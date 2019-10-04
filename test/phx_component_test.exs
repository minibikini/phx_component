defmodule PhxComponentTest do
  use ExUnit.Case
  doctest PhxComponent

  test "greets the world" do
    assert PhxComponent.hello() == :world
  end
end
