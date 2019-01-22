defmodule StitchTest do
  use ExUnit.Case
  doctest Stitch

  test "greets the world" do
    assert Stitch.hello() == :world
  end
end
