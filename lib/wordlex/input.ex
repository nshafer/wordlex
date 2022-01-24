# Copyright 2022 Nathan Shafer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

defmodule Wordlex.Shell do
  @spec get_char(String.t()) :: String.t() | nil
  def get_char(prompt) do
    IO.gets(prompt)
    |> String.trim()
    |> String.downcase()
    |> String.graphemes()
    |> Enum.filter(fn ch -> ch in Wordlex.List.valid_chars() end)
    |> Enum.take(1)
    |> then(fn
      [] -> nil
      [ch] -> ch
    end)
  end

  @spec get_chars(String.t()) :: list(String.t())
  def get_chars(prompt) do
    IO.gets(prompt)
    |> String.trim()
    |> String.downcase()
    |> String.graphemes()
    |> Enum.filter(fn ch -> ch in Wordlex.List.valid_chars() end)
    |> Enum.uniq()
  end

  @spec format_chars(list(String.t), String.t) :: String.t
  def format_chars(chars, joiner \\ "") do
    chars
    |> Enum.map(fn
      nil -> "_"
      ch -> ch
    end)
    |> Enum.join(joiner)
  end

  @spec format_list_of_chars(list(String.t), String.t, String.t) :: String.t
  def format_list_of_chars(list, char_joiner \\ "", list_joiner \\ "") do
    list
    |> Enum.map(fn chars -> format_chars(chars, char_joiner) end)
    |> Enum.map(fn chars -> "[#{chars}]" end)
    |> Enum.join(list_joiner)
  end
end
