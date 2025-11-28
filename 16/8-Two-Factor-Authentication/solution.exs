#!/usr/bin/env elixir

{width, height} = {50, 6}

pixels =
  "input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.reduce(MapSet.new(), fn
    "rect " <> rest, acc ->
      [_, w, h] = Regex.run(~r/(\d+)x(\d+)/, rest)
      {w, h} = {String.to_integer(w), String.to_integer(h)}
      for x <- 0..(w - 1), y <- 0..(h - 1), into: acc, do: {x, y}

    "rotate row y=" <> rest, acc ->
      [_, r, amt] = Regex.run(~r/(\d+) by (\d+)/, rest)
      {r, amt} = {String.to_integer(r), String.to_integer(amt)}

      acc
      |> Enum.map(fn
        {x, ^r} -> {rem(x + amt, width), r}
        other -> other
      end)
      |> MapSet.new()

    "rotate column x=" <> rest, acc ->
      [_, c, amt] = Regex.run(~r/(\d+) by (\d+)/, rest)
      c = String.to_integer(c)
      amt = String.to_integer(amt)

      acc
      |> Enum.map(fn
        {^c, y} -> {c, rem(y + amt, height)}
        other -> other
      end)
      |> MapSet.new()
  end)

lit_count = MapSet.size(pixels)

IO.puts("Part 1 - Pixels lit: #{lit_count}\n")

IO.puts("Part 2 - Screen output:\n")

for y <- 0..(height - 1) do
  row =
    for x <- 0..(width - 1) do
      if MapSet.member?(pixels, {x, y}), do: "#", else: "."
    end
    |> Enum.join()

  IO.puts(row)
end
