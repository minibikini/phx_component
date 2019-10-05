defmodule PhxComponent do
  @moduledoc """
  Documentation for PhxComponent.
  """

  def table(collection, opts) do
    PhxComponent.TableComponent.render(collection, opts)
  end
end
