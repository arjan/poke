defmodule Poke.NifTest do
  use ExUnit.Case

  alias Poke.Nif

  test "poke new / fetch" do
    {:ok, r} = Nif.new(10)
    assert <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0>> = Nif.fetch(r)
  end

  test "new w/ binary" do
    {:ok, r} = Nif.new("tonći")
    assert "tonći" = Nif.fetch(r)
    assert :ok = Nif.poke(r, 0, ?T)
    assert "Tonći" = Nif.fetch(r)
  end

  test "poke" do
    {:ok, r} = Nif.new(10)
    assert :ok = Nif.poke(r, 1, 254)
    assert <<0, 254, 0, 0, 0, 0, 0, 0, 0, 0>> = Nif.fetch(r)
    assert :ok = Nif.poke(r, 0, 23)
    assert <<23, 254, 0, 0, 0, 0, 0, 0, 0, 0>> = Nif.fetch(r)

    spawn(fn ->
      assert :ok = Nif.poke(r, 3, 30)
    end)

    Process.sleep(100)

    assert <<23, 254, 0, 30, 0, 0, 0, 0, 0, 0>> = Nif.fetch(r)
  end

  test "poke w/ binary" do
    {:ok, r} = Nif.new(5)
    assert :ok = Nif.poke(r, 0, "arjan")
    assert "arjan" = Nif.fetch(r)
  end
end
