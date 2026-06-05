#!/usr/bin/env bb

(ns solution2
  (:require [clojure.java.io :as io]
            [clojure.string :as str]))

(def ^:private base-dir
  (-> (or *file* ".")
      io/file
      .getAbsoluteFile
      .getParent))

(def directions [[1 0] [-1 0] [0 1] [0 -1]])

(defn resolve-path [filename]
  (str (io/file base-dir filename)))

(defn parse-line [line]
  (mapv Long/parseLong (str/split line #",")))

(defn parse-input [path]
  (->> path
       slurp
       str/trimr
       str/split-lines
       (mapv parse-line)))

(defn inclusive-range [a b]
  (range (min a b) (inc (max a b))))

(defn rectangle-area [[x1 y1] [x2 y2]]
  (* (inc (abs (- x1 x2)))
     (inc (abs (- y1 y2)))))

(defn point-pairs [points]
  (for [i (range (count points))
        j (range (inc i) (count points))]
    [(points i) (points j)]))

(defn axis-index [points coordinate]
  (let [values (->> points (map coordinate) distinct sort vec)]
    {:coord->idx (zipmap values (range 1 (inc (count values))))
     :size (+ 2 (count values))}))

(defn polygon-edges [points]
  (map vector points (concat (rest points) [(first points)])))

(defn walk-segment [[x1 y1] [x2 y2]]
  (if (= x1 x2)
    (map #(vector x1 %) (inclusive-range y1 y2))
    (map #(vector % y1) (inclusive-range x1 x2))))

(defn in-bounds? [width height [x y]]
  (and (<= 0 x (dec width))
       (<= 0 y (dec height))))

(defn flood-outside [width height walls]
  (loop [queue (conj clojure.lang.PersistentQueue/EMPTY [0 0])
         seen #{[0 0]}]
    (if-let [[x y] (peek queue)]
      (let [next-points (for [[dx dy] directions
                              :let [candidate [(+ x dx) (+ y dy)]]
                              :when (and (in-bounds? width height candidate)
                                         (not (walls candidate))
                                         (not (seen candidate)))]
                          candidate)]
        (recur (into (pop queue) next-points)
               (into seen next-points)))
      seen)))

(defn build-polygon-grid [points]
  (let [{x->idx :coord->idx width :size} (axis-index points first)
        {y->idx :coord->idx height :size} (axis-index points second)
        walls (into #{}
                    (mapcat (fn [[[x1 y1] [x2 y2]]]
                              (walk-segment [(x->idx x1) (y->idx y1)]
                                            [(x->idx x2) (y->idx y2)])))
                    (polygon-edges points))]
    {:x->idx x->idx
     :y->idx y->idx
     :outside (flood-outside width height walls)}))

(defn rectangle-border [[x1 y1] [x2 y2]]
  (let [xs (inclusive-range x1 x2)
        ys (inclusive-range y1 y2)
        xmin (min x1 x2)
        xmax (max x1 x2)
        ymin (min y1 y2)
        ymax (max y1 y2)]
    (concat (map #(vector % ymin) xs)
            (map #(vector % ymax) xs)
            (map #(vector xmin %) ys)
            (map #(vector xmax %) ys))))

(defn rectangle-inside? [{:keys [x->idx y->idx outside]} [x1 y1] [x2 y2]]
  (not-any? outside
            (rectangle-border [(x->idx x1) (y->idx y1)]
                              [(x->idx x2) (y->idx y2)])))

(defn solve-part1 [path]
  (let [points (parse-input path)]
    (reduce max 0 (map (fn [[a b]] (rectangle-area a b))
                       (point-pairs points)))))

(defn solve-part2 [path]
  (let [points (parse-input path)
        polygon (build-polygon-grid points)]
    (or (some (fn [[a b]]
                (let [area (rectangle-area a b)]
                  (when (rectangle-inside? polygon a b)
                    area)))
              (sort-by (fn [[a b]] (rectangle-area a b)) >
                       (point-pairs points)))
        0)))

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 50 (solve-part1 example-file)))
    (assert (= 24 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
