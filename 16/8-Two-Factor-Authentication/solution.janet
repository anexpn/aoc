#!/usr/bin/env janet

# ABOUTME: Advent of Code 2016 Day 8 - Two-Factor Authentication solution
# ABOUTME: Simulates a screen with pixel operations (rect, rotate row, rotate column)

(def width 50)
(def height 6)

(def grammar
  ~{:rect (* "rect " (constant :rect) (number :d+) "x" (number :d+))
    :row (* "rotate row y=" (constant :row) (number :d+) " by " (number :d+))
    :col (* "rotate column x=" (constant :col) (number :d+) " by " (number :d+))
    :main (+ :rect :row :col)})

(defn parse [line]
  (peg/match grammar line))

(defmacro rotate [direction pixels idx amt]
  (def [iter-var dimension get-coord new-coord]
    (case direction
      :row ['x 'width
            ~[x ,idx]
            ~[(mod (+ x ,amt) width) ,idx]]
      :col ['y 'height
            ~[,idx y]
            ~[,idx (mod (+ y ,amt) height)]]))
  ~(let [rotated (seq [,iter-var :range [0 ,dimension] :when (,pixels ,get-coord)] ,new-coord)]
     (loop [,iter-var :range [0 ,dimension]]
           (put ,pixels ,get-coord nil))
     (each p rotated (put ,pixels p true))))

(defn apply-instr [pixels instr]
  (match instr
    [:rect w h] (loop [x :range [0 w] y :range [0 h]]
                   (put pixels [x y] true))
    [:row r a] (rotate :row pixels r a)
    [:col c a] (rotate :col pixels c a)))

(def pixels
  (let [instrs (->> "input.txt"
          (slurp)
          (string/trim)
          (string/split "\n")
          (map parse))
        ps @{}]
    (do
      (each instr instrs (apply-instr ps instr))
      ps)))

(print "Part 1 - Pixels lit: " (length pixels) "\n")
(print "Part 2 - Screen output:\n")
(loop [y :range [0 height]]
  (print (string/join (seq [x :range [0 width]] (if (pixels [x y]) "#" ".")) "")))
