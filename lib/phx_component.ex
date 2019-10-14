defmodule PhxComponent do
  @moduledoc """
  Documentation for PhxComponent.
  """

  def table(collection, opts) do
    PhxComponent.TableComponent.render(collection, opts)
  end

  def table_card(item, opts) do
    PhxComponent.TableCardComponent.render(item, opts)
  end
end
