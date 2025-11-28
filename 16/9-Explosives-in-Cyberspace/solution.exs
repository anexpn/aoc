#!/usr/bin/env elixir

defmodule Solution.Part1 do
  def solve() do
    text = File.read!("input.txt")

    parse_text(text)
  end

  def parse_text(text) do
    parser = %{
      result: "",
      remaining: text,
      mode: :normal,
      buffer: "",
      repeat_chars: 0,
      repeat_times: 0
    }

    parse(parser).result
  end

  def parse(%{mode: :normal, remaining: ""} = parser), do: parser

  def parse(%{mode: :normal, remaining: "(" <> rest} = parser) do
    parse(%{parser | mode: :repeat_read_chars, remaining: rest})
  end

  def parse(
        %{mode: :normal, remaining: <<char::binary-size(1)>> <> rest, result: result} =
          parser
      ) do
    parse(%{parser | result: result <> char, remaining: rest})
  end

  def parse(%{mode: :repeat_read_chars, remaining: "x" <> rest, buffer: buffer} = parser) do
    parse(%{
      parser
      | mode: :repeat_read_times,
        repeat_chars: String.to_integer(buffer),
        buffer: "",
        remaining: rest
    })
  end

  def parse(
        %{mode: :repeat_read_chars, remaining: <<char::binary-size(1)>> <> rest, buffer: buffer} =
          parser
      ) do
    parse(%{parser | buffer: buffer <> char, remaining: rest})
  end

  def parse(
        %{
          mode: :repeat_read_times,
          remaining: ")" <> rest,
          buffer: buffer
        } = parser
      ) do
    parse(%{
      parser
      | mode: :repeat_do,
        repeat_times: String.to_integer(buffer),
        buffer: "",
        remaining: rest
    })
  end

  def parse(
        %{
          mode: :repeat_read_times,
          remaining: <<char::binary-size(1)>> <> rest,
          buffer: buffer
        } = parser
      ) do
    parse(%{parser | buffer: buffer <> char, remaining: rest})
  end

  def parse(
        %{
          mode: :repeat_do,
          repeat_chars: 0,
          repeat_times: 0
        } = parser
      ) do
    parse(%{parser | mode: :normal, buffer: ""})
  end

  def parse(
        %{
          mode: :repeat_do,
          repeat_chars: 0,
          repeat_times: repeat_times,
          result: result,
          buffer: buffer
        } = parser
      ) do
    parse(%{
      parser
      | repeat_times: repeat_times - 1,
        result: result <> buffer
    })
  end

  def parse(
        %{
          mode: :repeat_do,
          repeat_chars: repeat_chars,
          remaining: <<char::binary-size(1)>> <> rest,
          buffer: buffer
        } = parser
      ) do
    parse(%{
      parser
      | repeat_chars: repeat_chars - 1,
        buffer: buffer <> char,
        remaining: rest
    })
  end
end

defmodule Solution.Part2 do
  def solve() do
    text = File.read!("input.txt")

    parse_text(text)
  end

  def parse_text(text) do
    parser = %{
      result: 0,
      remaining: text,
      mode: :normal,
      buffer: "",
      buffer_result: 0,
      repeat_chars: 0,
      repeat_times: 0
    }

    parse(parser).result
  end

  def parse(%{mode: :normal, remaining: ""} = parser), do: parser

  def parse(%{mode: :normal, remaining: "(" <> rest} = parser) do
    parse(%{parser | mode: :repeat_read_chars, remaining: rest})
  end

  def parse(
        %{mode: :normal, remaining: <<_::binary-size(1)>> <> rest, result: result} =
          parser
      ) do
    parse(%{parser | result: result + 1, remaining: rest})
  end

  def parse(%{mode: :repeat_read_chars, remaining: "x" <> rest, buffer: buffer} = parser) do
    parse(%{
      parser
      | mode: :repeat_read_times,
        repeat_chars: String.to_integer(buffer),
        buffer: "",
        remaining: rest
    })
  end

  def parse(
        %{mode: :repeat_read_chars, remaining: <<char::binary-size(1)>> <> rest, buffer: buffer} =
          parser
      ) do
    parse(%{parser | buffer: buffer <> char, remaining: rest})
  end

  def parse(
        %{
          mode: :repeat_read_times,
          remaining: ")" <> rest,
          buffer: buffer
        } = parser
      ) do
    parse(%{
      parser
      | mode: :repeat_do_chars,
        repeat_times: String.to_integer(buffer),
        buffer: "",
        remaining: rest
    })
  end

  def parse(
        %{
          mode: :repeat_read_times,
          remaining: <<char::binary-size(1)>> <> rest,
          buffer: buffer
        } = parser
      ) do
    parse(%{parser | buffer: buffer <> char, remaining: rest})
  end

  def parse(
        %{
          mode: :repeat_do_chars,
          repeat_chars: 0,
          buffer: buffer
        } = parser
      ) do
    parse(%{
      parser
      | mode: :repeat_do_times,
        buffer_result: parse_text(buffer),
        buffer: ""
    })
  end

  def parse(
        %{
          mode: :repeat_do_chars,
          repeat_chars: repeat_chars,
          buffer: buffer,
          remaining: <<char::binary-size(1)>> <> rest
        } = parser
      ) do
    parse(%{
      parser
      | buffer: buffer <> char,
        repeat_chars: repeat_chars - 1,
        remaining: rest
    })
  end

  def parse(
        %{
          mode: :repeat_do_times,
          repeat_times: 0
        } = parser
      ) do
    parse(%{
      parser
      | mode: :normal,
        buffer_result: 0
    })
  end

  def parse(
        %{
          mode: :repeat_do_times,
          repeat_times: repeat_times,
          result: result,
          buffer_result: buffer_result
        } = parser
      ) do
    parse(%{
      parser
      | repeat_times: repeat_times - 1,
        result: result + buffer_result
    })
  end
end

result = Solution.Part1.solve()

IO.puts("Part 1 - Decompressed length: #{String.length(result)}")

result = Solution.Part2.solve()

IO.puts("Part 2 - Decompressed length: #{result}")
