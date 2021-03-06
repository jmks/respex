defmodule Respex.Encoder.Types do
  @moduledoc """
  Some helper methods to wrap values so they are encoded as the correct type.

  For example, to encode a list of an integer, an error, and a simple string,
  you could call:

  Respex.Encoder.encode([
    123,
    Respex.Encoder.Types.simple_string("abc"),
    Respex.Encoder.Types.error("I did it again", "OOPS")
  ])
  """

  def simple_string(str), do: {:simple_string, str}

  def error(message, prefix \\ ""), do: {:error, message, prefix}
end
