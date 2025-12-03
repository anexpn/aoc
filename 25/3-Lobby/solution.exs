defmodule Solution do
  def solve_part1 do
    parse()
    |> Enum.map(&max_joltage/1)
    |> Enum.sum()
  end

  def solve_part2 do
    parse()
    |> Enum.map(&max_joltage_2/1)
    |> Enum.sum()
  end

  def parse do
    args = System.argv()

    file = if length(args) > 0, do: hd(args), else: "input.txt"

    file
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def max_joltage(line) do
    digits = for <<c <- line>>, do: c - ?0
    len = length(digits)

    {lmax, rmax} =
      digits
      |> Enum.with_index()
      |> Enum.reduce({0, 0}, fn {digit, i}, {lmax, rmax} ->
        cond do
          digit > lmax and i != len - 1 ->
            {digit, 0}

          digit > rmax ->
            {lmax, digit}

          true ->
            {lmax, rmax}
        end
      end)

    lmax * 10 + rmax
  end

  def max_joltage_2(line) do
    digits = for <<c <- line>>, do: c - ?0
    len = length(digits)

    seq = List.duplicate(0, 12)

    seq =
      digits
      |> Enum.with_index()
      |> Enum.reduce(seq, fn {digit, i}, seq ->
        {seq, _} =
          seq
          |> Enum.with_index()
          |> Enum.reduce({seq, false}, fn {y, k}, {acc, replaced} ->
            cond do
              replaced ->
                {List.replace_at(acc, k, 0), replaced}

              digit > y and k >= 12 + i - len ->
                {List.replace_at(acc, k, digit), true}

              true ->
                {acc, replaced}
            end
          end)

        seq
      end)

    seq
    |> Enum.reduce(0, &(&2 * 10 + &1))
  end
end

result = Solution.solve_part1()

IO.puts("Part 1 - Solution: #{result}")

result = Solution.solve_part2()

IO.puts("Part 2 - Solution: #{result}")
