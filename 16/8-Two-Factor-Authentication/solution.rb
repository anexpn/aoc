#!/usr/bin/env ruby

# ABOUTME: Advent of Code 2016 Day 8 - Two-Factor Authentication solution
# ABOUTME: Simulates a screen with pixel operations (rect, rotate row, rotate column)

require 'set'

W, H = 50, 6

def parse(line)
  case line
  when /^rect (\d+)x(\d+)$/           then { t: :rect, w: $1.to_i, h: $2.to_i }
  when /^rotate row y=(\d+) by (\d+)$/ then { t: :row, r: $1.to_i, a: $2.to_i }
  when /^rotate column x=(\d+) by (\d+)$/ then { t: :col, c: $1.to_i, a: $2.to_i }
  end
end

def apply(pixels, i)
  case i[:t]
  when :rect then (0...i[:w]).to_a.product((0...i[:h]).to_a).each { pixels.add(_1) }; pixels
  when :row  then pixels.map { |x,y| y == i[:r] ? [(x + i[:a]) % W, y] : [x,y] }.to_set
  when :col  then pixels.map { |x,y| x == i[:c] ? [x, (y + i[:a]) % H] : [x,y] }.to_set
  end
end

pixels = File.readlines('input.txt', chomp: true).map(&method(:parse)).reduce(Set.new, &method(:apply))

puts "Part 1 - Pixels lit: #{pixels.size}\n\n"
puts "Part 2 - Screen output:\n\n"
H.times { |y| puts W.times.map { |x| pixels.include?([x,y]) ? '#' : '.' }.join }
