defmodule RespexTest do
  use ExUnit.Case

  describe "encode" do
    test "simple strings" do
      assert {:ok, "+OK\r\n"} == Respex.encode_simple_string("OK")
      assert {:ok, "+Hello, World\r\n"} == Respex.encode_simple_string("Hello, World")
    end

    test "bulk strings" do
      assert {:ok, "$6\r\nfoobar\r\n"} == Respex.encode_bulk_string("foobar")
      assert {:ok, "$0\r\n\r\n"} == Respex.encode_bulk_string("")
    end

    test "nil" do
      assert {:ok, "$-1\r\n"} == Respex.encode(nil)
    end

    test "integers" do
      assert {:ok, ":0\r\n"} == Respex.encode(0)
      assert {:ok, ":1000\r\n"} == Respex.encode(1000)
    end
  end
end
