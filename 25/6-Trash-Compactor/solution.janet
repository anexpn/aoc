#!/usr/bin/env janet

(defn parse
  [content]
  (def grammar
    ~{
      :sep (any " ")
      :numbers (group (* :sep (some (* (number :d+) :sep))))
      :ops (group (* :sep (some (* (<- (+ "*" "+")) :sep))))
      :main (split "\n" (+ :numbers :ops))
    })
  (peg/match grammar content))

(defn solve_part1
  [file]
  (def ns_ops (->> file
                (slurp)
                (parse)))
  (def ops (array/pop ns_ops))
  (def ns ns_ops)
  (var s 0)
  (for i 0 (length ops)
    (+= s (({"*" * "+" +} (ops i)) ;(map |($ i) ns))))
  s)

(defn parse2
  [content]
  (def grammar
    ~{
      :sep (any " ")
      :numbers (group (* :sep (some (* (column) (<- :d+) (column) :sep))))
      :ops (group (* :sep (some (* (<- (+ "*" "+")) :sep))))
      :main (split "\n" (+ :numbers :ops))
    })
  (peg/match grammar content))

(defn column-number
  [col j]
  (var n 0)
  (each [l num r] col
    (when (and (>= j l) (< j r))
      (def idx (- j l))
      (def substr (string/slice num idx (+ idx 1)))
      (*= n 10)
      (+= n (scan-number substr))))
  n)

(defn select-numbers
  [ns i]
  (def col (map |(array/slice $ (* 3 i) (* 3 (+ i 1))) ns))
  (var leftmost math/inf)
  (var rightmost math/-inf)
  (each [l _ r] col
    (set leftmost (min leftmost l))
    (set rightmost (max rightmost r)))
  (seq [j :range [leftmost rightmost]]
    (column-number col j)))

(defn solve_part2
  [file]
  (def ns_ops (->> file
                (slurp)
                (parse2)))
  (def ops (array/pop ns_ops))
  (def ns ns_ops)
  (var s 0)
  (for i 0 (length ops)
    (let [op (ops i)]
       (+= s (({"*" * "+" +} op) ;(select-numbers ns i)))))
  s)


(defn main
  [&]
  (let [got (solve_part1 "example.txt")
        got2 (solve_part2 "example.txt")]
    (assert (= 4277556 got) (error (string "got: " got)))
    (assert (= 3263827 got2) (error (string "got2: " got2))))
  (print "Part 1 - Solution: " (solve_part1 "input.txt"))
  (print "Part 2 - Solution: " (solve_part2 "input.txt")))
