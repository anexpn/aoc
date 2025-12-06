defmodule Solution do
  def solve_part1 do
    set = parse()

    set
    |> Enum.sum_by(&if(accessible?(set, &1), do: 1, else: 0))
  end

  def solve_part2 do
    set = parse()
    remove_paper(0, set)
  end

  def remove_paper(rolls, set) do
    {removed, new_set} =
      set
      |> Enum.reduce({0, set}, fn p, {rolls, acc} ->
        if accessible?(acc, p) do
          {rolls + 1, MapSet.delete(acc, p)}
        else
          {rolls, acc}
        end
      end)

    if removed == 0 do
      rolls
    else
      remove_paper(rolls + removed, new_set)
    end
  end

  def parse do
    args = System.argv()

    file = if length(args) > 0, do: hd(args), else: "input.txt"

    file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, i}, acc ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        if c == "@" do
          MapSet.put(acc, {i, j})
        else
          acc
        end
      end)
    end)
  end

  def accessible?(set, {i, j}) do
    adj =
      for di <- -1..1, dj <- -1..1, di != 0 or dj != 0, reduce: 0 do
        acc -> acc + if(MapSet.member?(set, {i + di, j + dj}), do: 1, else: 0)
      end

    adj < 4
  end
end

result = Solution.solve_part1()

IO.puts("Part 1 - Solution: #{result}")

result = Solution.solve_part2()

IO.puts("Part 2 - Solution: #{result}")
