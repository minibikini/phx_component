defmodule PhxComponent.Table do
  @moduledoc false

  alias Phoenix.HTML.Link

  defstruct head: [],
            fields: [],
            class: "",
            body_extra: [],
            thead: [class: "thead-dark"],
            tbody: [],
            link_fun: &Link.link/2
end
