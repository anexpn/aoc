#!/usr/bin/env elixir

defmodule Solution do
  def solve_part1 do
    floors =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, &parse_line/2)

    {floors_with_ids, _} = assign_ids(floors)

    bfs(floors_with_ids)
  end

  def solve_part2 do
    floors =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, &parse_line/2)

    floors =
      Map.update!(floors, 1, fn items ->
        items ++
          [
            {"elerium", :generator},
            {"elerium", :microchip},
            {"dilithium", :generator},
            {"dilithium", :microchip}
          ]
      end)

    {floors_with_ids, _} = assign_ids(floors)

    bfs(floors_with_ids)
  end

  def assign_ids(floors) do
    elements =
      floors
      |> Enum.flat_map(fn {_floor, items} ->
        Enum.map(items, fn {element, _type} -> element end)
      end)
      |> Enum.uniq()
      |> Enum.sort()

    element_to_id =
      elements
      |> Enum.with_index(1)
      |> Map.new()

    floors_with_ids =
      floors
      |> Enum.map(fn {floor, items} ->
        items_with_ids =
          items
          |> Enum.map(fn {element, type} ->
            {Map.get(element_to_id, element), type}
          end)
          |> MapSet.new()

        {floor, items_with_ids}
      end)
      |> Map.new()

    {floors_with_ids, element_to_id}
  end

  def parse_line(line, floors) do
    floor =
      case line do
        "The first floor" <> _ -> 1
        "The second floor" <> _ -> 2
        "The third floor" <> _ -> 3
        "The fourth floor" <> _ -> 4
      end

    items = parse_items(line)

    Map.put(floors, floor, items)
  end

  def parse_items(line) do
    if String.contains?(line, "nothing relevant") do
      []
    else
      generators =
        ~r/(\w+) generator/
        |> Regex.scan(line)
        |> Enum.map(fn [_, element] -> {element, :generator} end)

      microchips =
        ~r/(\w+)-compatible microchip/
        |> Regex.scan(line)
        |> Enum.map(fn [_, element] -> {element, :microchip} end)

      generators ++ microchips
    end
  end

  def bfs(floors) do
    q = :queue.new()
    q = :queue.in({1, floors, 0}, q)
    search(q, MapSet.new())
  end

  defp search(q, visited) do
    case :queue.out(q) do
      {:empty, _} ->
        :not_found

      {{:value, {elevator, floors, steps}}, q_rest} ->
        state_key = {elevator, normalize_state(floors)}

        if MapSet.member?(visited, state_key) do
          search(q_rest, visited)
        else
          visited = MapSet.put(visited, state_key)

          if goal?(floors) do
            steps
          else
            next_states = move(elevator, floors)

            q_updated =
              Enum.reduce(next_states, q_rest, fn {next_elevator, next_floors}, acc ->
                :queue.in({next_elevator, next_floors, steps + 1}, acc)
              end)

            search(q_updated, visited)
          end
        end
    end
  end

  defp normalize_state(floors) do
    all_items =
      floors
      |> Enum.flat_map(fn {floor, items} ->
        Enum.map(items, fn {element_id, type} -> {element_id, type, floor} end)
      end)

    element_ids =
      all_items
      |> Enum.map(&elem(&1, 0))
      |> Enum.uniq()

    pairs =
      Enum.map(element_ids, fn element_id ->
        gen_floor =
          all_items
          |> Enum.find(fn {id, type, _} -> id == element_id and type == :generator end)
          |> case do
            nil -> nil
            {_, _, floor} -> floor
          end

        chip_floor =
          all_items
          |> Enum.find(fn {id, type, _} -> id == element_id and type == :microchip end)
          |> case do
            nil -> nil
            {_, _, floor} -> floor
          end

        {gen_floor, chip_floor}
      end)
      |> Enum.sort()

    pairs
  end

  defp goal?(floors) do
    Enum.all?(1..3, fn floor -> MapSet.size(Map.get(floors, floor)) == 0 end)
  end

  defp move(elevator, floors) do
    items = Map.get(floors, elevator)
    moves = select(items)

    Enum.flat_map(moves, fn moved ->
      Enum.flat_map([-1, 1], fn dir ->
        next_elevator = elevator + dir

        if next_elevator < 1 or next_elevator > 4 do
          []
        else
          next_floors =
            floors
            |> Map.update!(elevator, &MapSet.difference(&1, moved))
            |> Map.update!(next_elevator, &MapSet.union(&1, moved))

          if valid_floor?(Map.get(next_floors, elevator)) and
               valid_floor?(Map.get(next_floors, next_elevator)) do
            [{next_elevator, next_floors}]
          else
            []
          end
        end
      end)
    end)
  end

  defp select(items) do
    single_moves = Enum.map(items, fn item -> MapSet.new([item]) end)

    pair_moves =
      for x <- items, y <- items, x < y, do: MapSet.new([x, y])

    single_moves ++ pair_moves
  end

  defp valid_floor?(items) do
    generators =
      items
      |> Enum.filter(fn {_, type} -> type == :generator end)
      |> Enum.map(&elem(&1, 0))

    microchips = Enum.filter(items, fn {_, type} -> type == :microchip end)

    generators == [] or
      Enum.all?(microchips, fn {element, _} ->
        element in generators
      end)
  end
end

result = Solution.solve_part1()

IO.puts("Part 1 - Solution: #{result}")

result2 = Solution.solve_part2()

IO.puts("Part 2 - Solution: #{result2}")
