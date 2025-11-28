#!/usr/bin/env elixir

defmodule Solution do
  def solve_part1 do
    stop_at = fn chips -> chips in [[17, 61], [61, 17]] end

    {bots, _} = simulate(stop_at)

    {bot, _} = Enum.find(bots, fn {_, chips} -> stop_at.(chips) end)

    bot
  end

  def solve_part2 do
    {_, outputs} = simulate()

    0..2
    |> Enum.flat_map(fn bin -> outputs[bin] end)
    |> Enum.product()
  end

  def simulate(stop_at \\ nil) do
    "input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce({%{}, %{}}, fn
      {:value, chip, bot}, {bots, rules} ->
        {Map.update(bots, bot, [chip], &[chip | &1]), rules}

      {:give, bot, low_dest, high_dest}, {bots, rules} ->
        {bots, Map.put(rules, bot, {low_dest, high_dest})}
    end)
    |> step(%{}, stop_at)
  end

  defp step({bots, rules}, outputs, stop_at) do
    case Enum.find(bots, fn {_bot, chips} -> length(chips) == 2 end) do
      nil ->
        {bots, outputs}

      {id, chips} ->
        if stop_at != nil and stop_at.(chips) do
          {bots, outputs}
        else
          low = Enum.min(chips)
          high = Enum.max(chips)

          {low_dest, high_dest} = Map.fetch!(rules, id)

          bots = Map.delete(bots, id)

          {bots, outputs} = give(low, low_dest, bots, outputs)
          {bots, outputs} = give(high, high_dest, bots, outputs)

          step({bots, rules}, outputs, stop_at)
        end
    end
  end

  defp give(chip, {"bot", id}, bots, outputs) do
    {Map.update(bots, id, [chip], &[chip | &1]), outputs}
  end

  defp give(chip, {"output", id}, bots, outputs) do
    {bots, Map.update(outputs, id, [chip], &[chip | &1])}
  end

  def parse_line("value" <> _ = line) do
    [_, chip, bot] = Regex.run(~r/value (\d+) goes to bot (\d+)/, line)
    {:value, String.to_integer(chip), String.to_integer(bot)}
  end

  def parse_line("bot" <> _ = line) do
    [_, bot, low_type, low_id, high_type, high_id] =
      Regex.run(
        ~r/bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/,
        line
      )

    {:give, String.to_integer(bot), {low_type, String.to_integer(low_id)},
     {high_type, String.to_integer(high_id)}}
  end
end

result = Solution.solve_part1()

IO.puts(
  "Part 1 - The number of the bot that is responsible for comparing value-61 microchip and value-17 microchip is: #{result}"
)

result = Solution.solve_part2()

IO.puts("Part 2 - The product of the values in output bins 0, 1, and 2 is: #{result}")
