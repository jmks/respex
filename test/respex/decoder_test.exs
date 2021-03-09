defmodule Respex.DecoderTest do
  use ExUnit.Case, async: true

  alias Respex.Decoder

  import Respex.Decoder

  describe "decode" do
    test "strings" do
      assert {:ok, "OK"} == decode("+OK\r\n")
      assert {:ok, "foobar"} == decode("$6\r\nfoobar\r\n")
      assert {:ok, ""} == decode("$0\r\n\r\n")
    end

    test "integers" do
      assert {:ok, 0} == decode(":0\r\n")
      assert {:ok, 1000} == decode(":1000\r\n")
    end

    test "arrays" do
      assert {:ok, []} == decode("*0\r\n")
      assert {:ok, [1,2,3]} == decode("*3\r\n:1\r\n:2\r\n:3\r\n")
      assert {:ok, ["foo", 1000]} == decode("*2\r\n$3\r\nfoo\r\n:1000\r\n")
    end

    test "nils" do
      assert {:ok, nil} == decode("$-1\r\n")
      assert {:ok, nil} == decode("*-1\r\n")
    end

    test "errors" do
      assert_raise Decoder.Error, ~r/unknown command/, fn ->
        decode("-ERR unknown command 'foobar'\r\n")
      end

      assert_raise Decoder.Error, ~r/WRONGTYPE/, fn ->
        decode("-WRONGTYPE Operation against a key holding the wrong kind of value\r\n")
      end
    end
  end
end
