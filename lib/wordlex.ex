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

defmodule Wordlex do
  @type gray_list :: list(binary)
  @type yellow_list :: list(nil | list(binary))
  @type green_list :: list(nil | binary)

  @doc """
  Runs an infinite loop asking for input.
  """
  @spec run :: no_return()
  def run() do
    IO.puts("""
    Wordle Solver

    This will attempt to brute force solve a wordle puzzle based on the information at hand.

    All inputs are lists of letters, such as "abcd", but you can separate them with
    anything if you want.
    """)

    grays = Wordlex.Shell.get_chars("Please enter all gray letters shown so far: ")

    IO.puts("""

    Now I need to ask about all of the letters that have shown up as yellow so
    far. Since there can be multiple yellows in each position of the word, I'll
    ask you for each one in turn. If there are no yellows for a given position,
    just hit enter.
    """)

    yellows =
      [
        "Please enter all yellow letters in the position 1: ",
        "Please enter all yellow letters in the position 2: ",
        "Please enter all yellow letters in the position 3: ",
        "Please enter all yellow letters in the position 4: ",
        "Please enter all yellow letters in the position 5: "
      ]
      |> Enum.map(fn prompt -> Wordlex.Shell.get_chars(prompt) end)

    IO.puts("""

    Finally, tell me which letters have appeared as green so far. I'll ask
    about each position. If there is no green in that position, just hit enter.
    """)

    greens =
      [
        "Please enter any green letter in position 1: ",
        "Please enter any green letter in position 2: ",
        "Please enter any green letter in position 3: ",
        "Please enter any green letter in position 4: ",
        "Please enter any green letter in position 5: "
      ]
      |> Enum.map(fn prompt -> Wordlex.Shell.get_char(prompt) end)

    case Wordlex.check_inputs(grays, yellows, greens) do
      :ok ->
        IO.puts("""

        Attempting to solve the puzzle with the following inputs:

        Gray letters:   #{Wordlex.Shell.format_chars(grays, ",")}
        Yellow letters: #{Wordlex.Shell.format_list_of_chars(yellows, ",", " ")}
        Green letters:  #{Wordlex.Shell.format_chars(greens, " ")}
        """)

        solutions = Wordlex.solve(grays, yellows, greens)
        num_solutions = length(solutions)

        case num_solutions do
          0 ->
            IO.puts(
              "Uh oh, no possible solutions found. Are you sure you entered everything correctly?"
            )

          1 ->
            IO.puts("The solution is: #{List.first(solutions)}")

          n when n < 10 ->
            IO.puts("There are #{num_solutions} possible solutions:\n#{Enum.join(solutions, "\n")}")

          n ->
            guesses = Enum.take_random(solutions, 5)

            IO.puts("""
            There are #{n} possible solutions! We need more information.

            Here are some random guesses to try next:
            #{Enum.join(guesses, "\n")}
            """)
        end

      {:error, errors} ->
        IO.puts("""

        There were problems found with your answers:
        #{Enum.join(errors, "\n")}
        """)
    end

    IO.puts("""

    ---------------------------

    """)

    run()
  end

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

  defp filter_grays(words, chars) do
    words
    |> Enum.reject(fn word -> String.contains?(word, chars) end)
  end

  # yellows is a list of positions in the word (length 5) and each entry is a list of yellow chars in that position.
  # so [["a", "b", "c"], ["a"], ["b", "c"], [], ["z"]] representing yellow a, b, c in position 0, a in 2, b and c in
  # the third spot, no yellows in the fourth spot and a yellow z in the fifth spot.
  defp filter_yellows(words, yellows) do
    yellow_regex = build_yellow_regex(yellows)

    words
    |> Enum.filter(fn word -> String.match?(word, yellow_regex) end)
  end

  defp build_yellow_regex(yellows) do
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
  defp filter_greens(words, chars) do
    green_regex = build_green_regex(chars)

    words
    |> Enum.filter(fn word -> String.match?(word, green_regex) end)
  end

  defp build_green_regex(chars) do
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

  defp check_grays_in_yellows(errors, grays, yellows) do
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

  defp check_grays_in_greens(errors, grays, greens) do
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

  defp check_yellows_in_green_spots(errors, yellows, greens) do
    greens
    |> Enum.with_index()
    |> Enum.reject(fn {green, _i} -> green == nil end)
    |> Enum.reduce(errors, fn {green, i}, errors ->
      yellows = Enum.at(yellows, i)

      if yellows != nil and green in yellows do
        ["Green letter #{green} was also given as yellow in position #{i + 1}" | errors]
      else
        errors
      end
    end)
  end
end
