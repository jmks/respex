defmodule Respex do
  @moduledoc """
  Respex
  """

  @cr "\r"
  @lf "\n"
  @crlf @cr <> @lf

  def encode(value)

  @doc """
  Encoding for nil.

  Encoded as a bulk string with size -1
  """
  def encode(nil), do: {:ok, "$-1\r\n"}

  def encode(string) when is_binary(string) do
    encode_bulk_string(string)
  end

  def encode(int) when is_integer(int) do
    {:ok, join([":", int, @crlf])}
  end

  def encode(list) when is_list(list) do
    count = length(list)
    encoded_contents = Enum.map(list, &encode/1)

    if Enum.all?(encoded_contents, fn {state, _} -> state == :ok end) do
      contents = Enum.map(encoded_contents, fn {:ok, e} -> e end)

      {:ok, join(["*", count, @crlf, contents])}
    else
      Enum.find(encoded_contents, fn {state, _} -> state == :error end)
    end
  end

  def encode_error(message, prefix \\ "") do
    encoded_message = if prefix == "" do
      message
    else
      "#{prefix} #{message}"
    end

    {:ok, join(["-", encoded_message])}
  end

  def encode_simple_string(string) when is_binary(string) do
    if bulk_string?(string) do
      {:error, "string contains #{@cr} or #{@lf}"}
    else
      {:ok, join(["+", string, @crlf])}
    end
  end

  def encode_bulk_string(string) do
    bytes = byte_size(string)

    {:ok, join(["$", bytes, @crlf, string, @crlf])}
  end

  defp bulk_string?(string) do
    String.contains?(string, @cr) or String.contains?(string, @lf)
  end

  defp join(parts) do
    Enum.join(parts, "")
  end
end
