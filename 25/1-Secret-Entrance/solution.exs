defmodule Solution do
  def solve_part1 do
    {password, _} =
      parse()
      |> Enum.reduce({0, 50}, fn dist, {cnt, point} ->
        point = rem(point + dist, 100)
        point = if point < 0, do: point + 100, else: point
        {cnt + if(point == 0, do: 1, else: 0), point}
      end)

    password
  end

  def solve_part2 do
    {password, _} =
      parse()
      |> Enum.reduce({0, 50}, fn dist, {cnt, point} ->
        dest = point + dist
        {q, r} = {div(dest, 100), rem(dest, 100)}

        cnt = cnt + if point > 0 and dest <= 0, do: 1, else: 0
        cnt = cnt + abs(q)

        {cnt, if(r < 0, do: 100 + r, else: r)}
      end)

    password
  end

  def parse do
    args = System.argv()
    file = if length(args) > 0, do: hd(args), else: "input.txt"

    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    case line do
      "L" <> dist -> -String.to_integer(dist)
      "R" <> dist -> String.to_integer(dist)
    end
  end
end

result = Solution.solve_part1()

IO.puts("Part 1 - Password: #{result}")

result = Solution.solve_part2()

IO.puts("Part 2 - Password: #{result}")
