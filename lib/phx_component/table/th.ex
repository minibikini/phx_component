defmodule PhxComponent.Table.Th do
  @moduledoc false

  defstruct value: nil, class: nil

  def normalize(%{} = item) do
    struct(__MODULE__, item)
  end

  def normalize(item) do
    normalize(%{value: item})
  end
end
