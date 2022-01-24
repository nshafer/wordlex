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

  def format_chars(chars, joiner \\ "") do
    chars
    |> Enum.map(fn
      nil -> "_"
      ch -> ch
    end)
    |> Enum.join(joiner)
  end

  def format_list_of_chars(list, char_joiner \\ "", list_joiner \\ "") do
    list
    |> Enum.map(fn chars -> format_chars(chars, char_joiner) end)
    |> Enum.map(fn chars -> "[#{chars}]" end)
    |> Enum.join(list_joiner)
  end
end
