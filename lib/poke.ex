defmodule Poke do
  @moduledoc """
  Poke it.
  """

  alias Poke.Nif

  defdelegate new(size_or_binary), to: Nif
  defdelegate fetch(resource), to: Nif
  defdelegate poke(resource, pos, char_or_binary), to: Nif
end
