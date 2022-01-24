defmodule Wordlex do
  @type gray_list :: list(binary)
  @type yellow_list :: list(nil | list(binary))
  @type green_list :: list(nil | binary)

  @doc """
  Attempt to solve the given puzzle with the given input.

  `grays` is a list of characters that have turned up gray, Example: `["l", "a", "m", "b"]`.

  `yellows` is a list of characters that appear yellow in each position, so the length must be 5. If there are no
  yellow characters for a given position, then pass `nil` or an empty list `[]`. Example:
  [["a", "b", "c"], ["a"], ["b", "c"], nil, ["z"]] representing yellow a, b, c in the first spot, a in the second,
  b and c in the third, no yellows in the fourth spot and a yellow z in the fifth spot.

  `greens` is a list of green characters in the spot that they have been reported in, or nil otherwise. Example:
  `[nil, "n", nil, "l", nil]` when "n" has turned green in the second spot, and "l" is green in the fourth.

  Returns a list of possible words that it might be. If more than one is returned, then more information is needed.
  If no words are returned, then this puzzle cannot be solved. Perhaps the built-in list of words is outdated.
  """
  @spec solve(gray_list, yellow_list, green_list) :: list(binary)
  def solve(grays, yellows, greens)
      when is_list(grays) and
             is_list(yellows) and length(yellows) == 5 and
             is_list(greens) and length(greens) == 5 do
    Wordlex.List.solutions()
    |> filter_grays(grays)
    |> filter_yellows(yellows)
    |> filter_greens(greens)
  end

  def filter_grays(words, chars) do
    words
    |> Enum.reject(fn word -> String.contains?(word, chars) end)
  end

  # yellows is a list of positions in the word (length 5) and each entry is a list of yellow chars in that position.
  # so [["a", "b", "c"], ["a"], ["b", "c"], [], ["z"]] representing yellow a, b, c in position 0, a in 2, b and c in
  # the third spot, no yellows in the fourth spot and a yellow z in the fifth spot.
  def filter_yellows(words, yellows) do
    yellow_regex = build_yellow_regex(yellows)

    words
    |> Enum.filter(fn word -> String.match?(word, yellow_regex) end)
  end

  def build_yellow_regex(yellows) do
    yellows
    |> Enum.map(fn
      nil -> "."
      [] -> "."
      chars -> "[^" <> Enum.join(chars) <> "]"
    end)
    |> Enum.join()
    |> Regex.compile!()
  end

  # Filter words with chars that match in the specific spot. `chars` should be a list representing each position of
  # the word, and each should be `nil` or the green char in that position.
  def filter_greens(words, chars) do
    green_regex = build_green_regex(chars)

    words
    |> Enum.filter(fn word -> String.match?(word, green_regex) end)
  end

  def build_green_regex(chars) do
    chars
    |> Enum.map(fn
      nil -> "."
      ch -> ch
    end)
    |> Enum.join()
    |> Regex.compile!()
  end

  @doc """
  Checks inputs for common issues, such as putting a letter in the "grays" as well as yellows and greens.
  """
  @spec check_inputs(gray_list, yellow_list, green_list) :: :ok | {:error, list(binary)}
  def check_inputs(grays, yellows, greens) do
    errors =
      []
      |> check_grays_in_yellows(grays, yellows)
      |> check_grays_in_greens(grays, greens)
      |> check_yellows_in_green_spots(yellows, greens)

    if length(errors) > 0 do
      {:error, errors}
    else
      :ok
    end
  end

  def check_grays_in_yellows(errors, grays, yellows) do
    yellows
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reduce(errors, fn yellow, errors ->
      if yellow in grays do
        ["Yellow letter #{yellow} was also given as a gray letter" | errors]
      else
        errors
      end
    end)
  end

  def check_grays_in_greens(errors, grays, greens) do
    greens
    |> Enum.reject(fn green -> green == nil end)
    |> Enum.reduce(errors, fn green, errors ->
      if green in grays do
        ["Green letter #{green} was also given as a gray letter" | errors]
      else
        errors
      end
    end)
  end

  def check_yellows_in_green_spots(errors, yellows, greens) do
    greens
    |> Enum.with_index()
    |> IO.inspect()
    |> Enum.reject(fn {green, _i} -> green == nil end)
    |> Enum.reduce(errors, fn {green, i}, errors ->
      yellows = Enum.at(yellows, i)
      if yellows != nil and green in yellows do
        ["Green letter #{green} was also given as yellow in position #{i+1}" | errors]
      else
        errors
      end
    end)
  end
end
