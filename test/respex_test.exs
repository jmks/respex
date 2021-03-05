defmodule RespexTest do
  use ExUnit.Case
  doctest Respex

  test "greets the world" do
    assert Respex.hello() == :world
  end
end
