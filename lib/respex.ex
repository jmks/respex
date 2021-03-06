defmodule Respex do
  @moduledoc """
  Respex
  """

  @cr "\r"
  @lf "\n"
  @crlf @cr <> @lf

  def encode_simple_string(string) when is_binary(string) do
    if bulk_string?(string) do
      {:error, "string contains #{@cr} or #{@lf}"}
    else
      encoded = Enum.join(["+", string, @crlf], "")

      {:ok, encoded}
    end
  end

  def encode_bulk_string(string) do
    bytes = byte_size(string)
    encoded = Enum.join(["$", bytes, @crlf, string, @crlf])

    {:ok, encoded}
  end

  defp bulk_string?(string) do
    String.contains?(string, @cr) or String.contains?(string, @lf)
  end

  # def decode(string) when is_binary(string)
end
