defmodule RespexTest do
  use ExUnit.Case

  describe "encode" do
    test "encode simple strings" do
      assert {:ok, "+OK\r\n"} == Respex.encode_simple_string("OK")
      assert {:ok, "+Hello, World\r\n"} == Respex.encode_simple_string("Hello, World")
    end

    test "encode bulk strings" do
      assert {:ok, "$6\r\nfoobar\r\n"} == Respex.encode_bulk_string("foobar")
      assert {:ok, "$0\r\n\r\n"} == Respex.encode_bulk_string("")
    end
  end
end
