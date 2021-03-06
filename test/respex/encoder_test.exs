defmodule EncoderTest do
  use ExUnit.Case

  alias Respex.Encoder.Types

  import Respex.Encoder

  describe "encode" do
    test "simple strings" do
      assert {:ok, "+OK\r\n"} == encode_simple_string("OK")
      assert {:ok, "+Hello, World\r\n"} == encode_simple_string("Hello, World")

      assert {:error, "string contains \r or \n"} == encode_simple_string("Hello\rWorld")
    end

    test "bulk strings" do
      assert {:ok, "$6\r\nfoobar\r\n"} == encode_bulk_string("foobar")
      assert {:ok, "$0\r\n\r\n"} == encode_bulk_string("")
    end

    test "nil" do
      assert {:ok, "$-1\r\n"} == encode(nil)
    end

    test "integers" do
      assert {:ok, ":0\r\n"} == encode(0)
      assert {:ok, ":1000\r\n"} == encode(1000)
    end

    test "errors" do
      assert {:ok, "-ERR unknown command 'foobar'\r\n"} == encode_error("unknown command 'foobar'", "ERR")
      assert {:ok, "-WRONGTYPE Operation against a key holding the wrong kind of value\r\n"} == encode_error("Operation against a key holding the wrong kind of value", "WRONGTYPE")
    end

    test "lists" do
      assert {:ok, "*0\r\n"} == encode([])
      assert {:ok, "*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"} == encode(["foo", "bar"])
      assert {:ok, "*3\r\n:1\r\n:2\r\n:3\r\n"} == encode([1,2,3])
      assert {:ok, "*5\r\n:1\r\n:2\r\n:3\r\n:4\r\n$6\r\nfoobar\r\n"} == encode([1,2,3,4,"foobar"])
      assert {:ok, "*3\r\n$3\r\nfoo\r\n$-1\r\n$3\r\nbar\r\n"} == encode(["foo",nil,"bar"])
      assert {:error, "can't encode %{a: 1}"} == encode([1, %{a: 1}])
    end

    test "list with mixed types" do
      list = [
        [1,2,3],
        [
          Types.simple_string("Foo"),
          Types.error("Bar")
        ]
      ]

      assert {:ok, "*2\r\n*3\r\n:1\r\n:2\r\n:3\r\n*2\r\n+Foo\r\n-Bar\r\n"} == encode(list)
    end
  end
end
