defmodule Poke.Nif do
  @on_load :init

  def init do
    file = :filename.join(:code.priv_dir(:poke), 'poke')
    :ok = :erlang.load_nif(file, 0)
  end

  def new(_size) do
    exit(:nif_library_not_loaded)
  end

  def fetch(_resource) do
    exit(:nif_library_not_loaded)
  end

  def poke(_resource, _pos, _char) do
    exit(:nif_library_not_loaded)
  end
end
