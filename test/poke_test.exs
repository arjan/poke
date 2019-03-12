defmodule PokeTest do
  use ExUnit.Case

  test "poke new / fetch" do
    {:ok, r} = Poke.new(10)
    assert <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0>> = Poke.fetch(r)
  end

  test "new w/ binary" do
    {:ok, r} = Poke.new("tonći")
    assert "tonći" = Poke.fetch(r)
    assert :ok = Poke.poke(r, 0, ?T)
    assert "Tonći" = Poke.fetch(r)
  end

  test "poke" do
    {:ok, r} = Poke.new(10)
    assert :ok = Poke.poke(r, 1, 254)
    assert <<0, 254, 0, 0, 0, 0, 0, 0, 0, 0>> = Poke.fetch(r)
    assert :ok = Poke.poke(r, 0, 23)
    assert <<23, 254, 0, 0, 0, 0, 0, 0, 0, 0>> = Poke.fetch(r)

    spawn(fn ->
      assert :ok = Poke.poke(r, 3, 30)
    end)

    Process.sleep(100)

    assert <<23, 254, 0, 30, 0, 0, 0, 0, 0, 0>> = Poke.fetch(r)
  end

  test "poke w/ binary" do
    {:ok, r} = Poke.new(5)
    assert :ok = Poke.poke(r, 0, "arjan")
    assert "arjan" = Poke.fetch(r)
  end
end
