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

    test "errors" do
      assert {:ok, "-ERR unknown command 'foobar'"} == Respex.encode_error("unknown command 'foobar'", "ERR")
      assert {:ok, "-WRONGTYPE Operation against a key holding the wrong kind of value"} == Respex.encode_error("Operation against a key holding the wrong kind of value", "WRONGTYPE")
    end

    test "lists" do
      assert {:ok, "*0\r\n"} == Respex.encode([])
      assert {:ok, "*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"} == Respex.encode(["foo", "bar"])
    end
  end
end
