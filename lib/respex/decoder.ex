defmodule Respex.Decoder do
  @cr "\r"
  @lf "\n"
  @crlf @cr <> @lf

  defmodule Error do
    defexception message: "decoding error"
  end

  def decode(string) do
    case decode(detect_type(string), string) do
      {:ok, value, ""} ->
        {:ok, value}

      {:ok, value, remaining} ->
        {:error, "decoded #{value} but had #{remaining} left"}

      {:error, error} ->
        {:error, error}
    end
  end

  def decode(:simple_string, "+" <> string) do
    case String.split(string, @crlf, parse: 2, trim: true) do
      [str] ->
        {:ok, str, ""}

      [str, rest] ->
        {:ok, str, rest}
    end
  end

  def decode(:bulk_string, "$" <> string) do
    case string |> trim_leading |> Integer.parse() do
      {-1, rest} ->
        {:ok, nil, trim_leading(rest)}

      {count, rest} ->
        {str, rest} = rest |> trim_leading |> String.split_at(count)

        {:ok, str, trim_leading(rest)}

      :error ->
        {:error, "could not parse string length from bulk string"}
    end
  end

  def decode(:integer, ":" <> string) do
    case Integer.parse(string) do
      {int, rest} ->
        {:ok, int, trim_leading(rest)}

      :error ->
        {:error, "could not decode integer from #{string}"}
    end
  end

  def decode(:array, "*" <> string) do
    case Integer.parse(string) do
      {-1, rest} ->
        {:ok, nil, trim_leading(rest)}

      {count, rest} ->
        decode_many(trim_leading(rest), count, [])

      :error ->
        {:error, "could not decode '*#{string}' as array"}
    end
  end

  def decode(:error, "-" <> string) do
    {:ok, message, _} = decode(:simple_string, "+" <> string)

    raise Error, message
  end

  defp decode_many(string, 0, acc), do: {:ok, Enum.reverse(acc), trim_leading(string)}

  defp decode_many(string, count, acc) do
    case decode(detect_type(string), string) do
      {:ok, value, rest} ->
        decode_many(rest, count - 1, [value | acc])

      {:error, error} ->
        {:error, error}
    end
  end

  defp detect_type(string) do
    case String.first(string) do
      "+" -> :simple_string
      "$" -> :bulk_string
      ":" -> :integer
      "*" -> :array
      "-" -> :error
    end
  end

  defp trim_leading(str), do: String.trim_leading(str, @crlf)
end
