defmodule Solution do
  def solve_part1 do
    vm =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> simulate()

    vm.regs["a"]
  end

  def solve_part2 do
    vm =
      "input.txt"
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> simulate(%{"c" => 1})

    vm.regs["a"]
  end

  def parse_line(line) do
    [opcode | args] = String.split(line)

    case opcode do
      "cpy" ->
        [src, dst] = args
        {:cpy, parse_value(src), dst}

      "inc" ->
        [reg] = args
        {:inc, reg}

      "dec" ->
        [reg] = args
        {:dec, reg}

      "jnz" ->
        [test, offset] = args
        {:jnz, parse_value(test), String.to_integer(offset)}
    end
  end

  defp parse_value(str) do
    case Integer.parse(str) do
      {int, ""} -> int
      :error -> str
    end
  end

  def simulate(insts, regs \\ %{}) do
    insts = :array.from_list(insts)
    vm = %{pc: 0, regs: Map.merge(%{"a" => 0, "b" => 0, "c" => 0, "d" => 0}, regs)}
    step(insts, vm)
  end

  def step(insts, %{pc: pc, regs: regs} = vm) do
    if pc > :array.size(insts) - 1 do
      vm
    else
      new_vm =
        case :array.get(pc, insts) do
          {:cpy, src, dst} ->
            value = resolve_value(src, regs)
            %{vm | regs: %{regs | dst => value}, pc: pc + 1}

          {:inc, reg} ->
            %{vm | regs: %{regs | reg => regs[reg] + 1}, pc: pc + 1}

          {:dec, reg} ->
            %{vm | regs: %{regs | reg => regs[reg] - 1}, pc: pc + 1}

          {:jnz, test, offset} ->
            value = resolve_value(test, regs)

            new_pc =
              if value != 0 do
                pc + offset
              else
                pc + 1
              end

            %{vm | pc: new_pc}
        end

      step(insts, new_vm)
    end
  end

  defp resolve_value(val, _regs) when is_integer(val), do: val
  defp resolve_value(reg, regs) when is_binary(reg), do: regs[reg]
end

result = Solution.solve_part1()

IO.puts("Part 1 - a is: #{result}")

result = Solution.solve_part2()

IO.puts("Part 2 - a is: #{result}")
