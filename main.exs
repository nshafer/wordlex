# Copyright <YEAR> <COPYRIGHT HOLDER>
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

IO.puts """
Wordle Solver

This will attempt to brute force solve a wordle puzzle based on the information at hand.

All inputs are lists of letters, such as "abcd", but you can separate them with
anything if you want.
"""

grays = Wordlex.Shell.get_chars("Please enter all gray letters shown so far: ")
IO.inspect(grays, label: "grays")

IO.puts """

Now I need to ask about all of the letters that have shown up as yellow so
far. Since there can be multiple yellows in each position of the word, I'll
ask you for each one in turn. If there are no yellows for a given position,
just hit enter.
"""

yellows =
  [
    "Please enter all yellow letters in the position 1: ",
    "Please enter all yellow letters in the position 2: ",
    "Please enter all yellow letters in the position 3: ",
    "Please enter all yellow letters in the position 4: ",
    "Please enter all yellow letters in the position 5: ",
  ]
  |> Enum.map(fn prompt -> Wordlex.Shell.get_chars(prompt) end)
IO.inspect(yellows, label: "yellows")

IO.puts """

Finally, tell me which letters have appeared as green so far. I'll ask
about each position. If there is no green in that position, just hit enter.
"""

greens =
  [
    "Please enter any green letter in position 1: ",
    "Please enter any green letter in position 2: ",
    "Please enter any green letter in position 3: ",
    "Please enter any green letter in position 4: ",
    "Please enter any green letter in position 5: ",
  ]
  |> Enum.map(fn prompt -> Wordlex.Shell.get_char(prompt) end)
IO.inspect(greens, label: "greens")

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
        IO.puts("Uh oh, no possible solutions found. Are you sure you entered everything correctly?")

      1 ->
        IO.puts("The solution is: #{List.first(solutions)}")

      n when n < 10 ->
        IO.puts("There are #{num_solutions} possible:\n#{Enum.join(solutions, "\n")}")

      n ->
        guesses = Enum.take_random(solutions, 5)

        IO.puts("""
        There are #{num_solutions} possible solutions! We need more information.

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
