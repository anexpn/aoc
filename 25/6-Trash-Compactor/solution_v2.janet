#!/usr/bin/env janet

# ABOUTME: Alternative solution for AOC 2025 Day 6 using direct grid reading
# ABOUTME: Simpler approach without PEG column position tracking

(defn solve_part2_v2
  [file]
  (def content (string/trimr (slurp file)))
  (def lines (string/split "\n" content))
  (def ops-line (last lines))
  (def num-rows (array/slice lines 0 -1))

  # Find all operation positions
  (def operations @[])
  (each [col char] (pairs ops-line)
    (when (or (= char (chr "*")) (= char (chr "+")))
      (array/push operations {:col col :op char})))

  # Find max column position across all rows (not just ops-line)
  (def max-col (max ;(map length num-rows)))

  # For each operation, find its number columns
  (var sum 0)
  (for i 0 (length operations)
    (def op-start (get-in operations [i :col]))
    (def op-end (if (< i (- (length operations) 1))
                    (get-in operations [(+ i 1) :col])
                    max-col))

    # Extract vertical numbers in this range
    (def numbers @[])
    (for col op-start op-end
      (def digits @[])
      (each row num-rows
        (def char (if (< col (length row)) (get row col) (chr " ")))
        (when (and (>= char (chr "0")) (<= char (chr "9")))
          (array/push digits char)))

      (when (> (length digits) 0)
        (array/push numbers (scan-number (string/from-bytes ;digits)))))

    # Apply operation
    (def op-char (get-in operations [i :op]))
    (def op-fn (if (= op-char (chr "*")) * +))
    (+= sum (op-fn ;numbers)))

  sum)

# Test with example
(defn main [&]
  (print "Testing new approach...")
  (def example-result (solve_part2_v2 "example.txt"))
  (print "Example result: " example-result)
  (assert (= example-result 3263827) (error (string "Example failed! Got: " example-result)))

  (print "\nPart 2 - Solution: " (solve_part2_v2 "input.txt")))
