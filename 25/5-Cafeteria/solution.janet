#!/usr/bin/env janet

(defn range<
  "Compare ranges for sorting: first by start position, then by end position"
  [[start1 end1] [start2 end2]]
  (or (< start1 start2)
      (and (= start1 start2) (< end1 end2))))

(defn parse
  [content]
  (def grammar
    ~{
      :range (* (number :d+) "-" (number :d+))
      :delim "\n"
      :id :d+
      :ranges (some (* (group :range) "\n"))
      :ids (some (* (number :id) (? "\n")))
      :main (* (group :ranges)
               :delim
               (group :ids))
    })
  (peg/match grammar content))

(defn in-any-range?
  "Check if an ID falls within any of the given ranges"
  [id ranges]
  (some |(and (>= id ($ 0)) (<= id ($ 1))) ranges))

(defn solve_part1
  [file]
  (def [ranges ids]
    (->> file
      (slurp)
      (string/trim)
      (parse)))
  (count |(in-any-range? $ ranges) ids))

(defn solve_part2
  [file]
  (def [ranges _]
    (->> file
      (slurp)
      (string/trim)
      (parse)))

  # Calculate union of all ranges by sorting and tracking overlaps
  (sort ranges range<)
  (var max-end math/-inf)
  (var total 0)

  (loop [[start end] :in ranges]
    (def range-size (+ 1 (- end start)))
    (def overlap (max 0 (+ 1 (- max-end start))))
    (+= total (max 0 (- range-size overlap)))
    (set max-end (max max-end end)))

  total)

(defn main
  [&]
  (let [got1 (solve_part1 "example.txt")
        got2 (solve_part2 "example.txt")]
    (assert (= 3 got1) (error (string "got1: " got1)))
    (assert (= 14 got2) (error (string "got2: " got2))))
  (print "Part 1 - Solution: " (solve_part1 "input.txt"))
  (print "Part 2 - Solution: " (solve_part2 "input.txt")))

