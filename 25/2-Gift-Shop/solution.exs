defmodule Solution do
  def solve_part1 do
    parse()
    |> Enum.map(&invalid_sum/1)
    |> Enum.sum()
  end

  def parse do
    args = System.argv()
    file = if length(args) > 0, do: Enum.at(args, 0), else: "input.txt"

    file
    |> File.read!()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.split(&1, "-"))
  end

  def invalid_sum([from, to]) do
    String.to_integer(from)..String.to_integer(to)
    |> Enum.reduce(0, fn x, acc -> if(invalid_id?(x), do: x + acc, else: acc) end)
  end

  def invalid_id?(id) do
    id_str = Integer.to_string(id)

    if rem(String.length(id_str), 2) == 0 do
      {left, right} = String.split_at(id_str, div(String.length(id_str), 2))
      left == right
    else
      false
    end
  end
end

defmodule Solution.Part2 do
  def solve_part2 do
    Solution.parse()
    |> Enum.map(&invalid_sum/1)
    |> Enum.sum()
  end

  def invalid_sum([from, to]) do
    String.to_integer(from)..String.to_integer(to)
    |> Enum.reduce(0, fn x, acc -> if(invalid_id?(x), do: x + acc, else: acc) end)
  end

  def invalid_id?(id) do
    invalid_id_str?(Integer.to_string(id))
  end

  def invalid_id_str?(id_str) do
    len = String.length(id_str)

    if len <= 1 do
      false
    else
      1..div(len, 2)
      |> Enum.any?(fn pattern_len ->
        if rem(len, pattern_len) == 0 do
          pattern = String.slice(id_str, 0, pattern_len)
          repetitions = div(len, pattern_len)

          repetitions >= 2 and String.duplicate(pattern, repetitions) == id_str
        else
          false
        end
      end)
    end
  end
end

result = Solution.solve_part1()

IO.puts("Part 1 - Solution: #{result}")

result = Solution.Part2.solve_part2()

IO.puts("Part 2 - Solution: #{result}")
