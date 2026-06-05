#!/usr/bin/env bb

(ns solution
  (:require [clojure.java.io :as io]
            [clojure.string :as str]))

(def ^:private base-dir
  (-> (or *file* ".")
      io/file
      .getAbsoluteFile
      .getParent))

(defn resolve-path [filename]
  (str (io/file base-dir filename)))

(defn parse-line [line]
  (mapv Long/parseLong (str/split line #",")))

(defn parse-input [path]
  (let [lines (-> path slurp str/trimr str/split-lines)]
    {:points (mapv parse-line lines)}))

(comment
  (parse-input "example.txt"))


(defn rect-area [a b]
  (reduce * (map (comp inc abs -) a b)))

(defn solve-part1 [path]
  (let [{:keys [points]} (parse-input path)]
    (reduce max (for [i (range (count points))
                      j (range (inc i) (count points))]
                  (rect-area (points i) (points j))))))

(comment
  (solve-part1 "example.txt"))

(defn build-polygon [points]
  (let [xs (->> points (map first) distinct sort vec)
        ys (->> points (map second) distinct sort vec)
        x->idx (zipmap xs (range 1 (+ 1 (count xs))))
        y->idx (zipmap ys (range 1 (+ 1 (count ys))))
        width (+ 2 (count xs))
        height (+ 2 (count ys))
        edges (map vector points (concat (subvec points 1) [(points 0)]))
        walls (reduce (fn [acc [[x1 y1] [x2 y2]]]
                        (let [ix1 (x->idx x1)
                              ix2 (x->idx x2)
                              iy1 (y->idx y1)
                              iy2 (y->idx y2)]
                          (if (= ix1 ix2)
                            (reduce (fn [acc' y]
                                      (conj acc' [ix1 y]))
                                    acc
                                    (range (min iy1 iy2) (inc (max iy1 iy2))))
                            (reduce (fn [acc' x]
                                      (conj acc' [x iy1]))
                                    acc
                                    (range (min ix1 ix2) (inc (max ix1 ix2)))))))
                      #{}
                      edges)
        outside (loop [queue (conj clojure.lang.PersistentQueue/EMPTY [0 0])
                       seen #{[0 0]}]
                  (if (empty? queue)
                    seen
                    (let [[x y] (peek queue)
                          queue' (pop queue)
                          next-points (for [[dx dy] [[1 0] [-1 0] [0 1] [0 -1]]
                                            :let [nx (+ x dx)
                                                  ny (+ y dy)
                                                  p [nx ny]]
                                            :when (and (<= 0 nx (dec width))
                                                       (<= 0 ny (dec height))
                                                       (not (walls p))
                                                       (not (seen p)))]
                                        p)]
                      (recur (into queue' next-points)
                             (into seen next-points)))))]
    {:x->idx x->idx
     :y->idx y->idx
     :outside outside}))

(comment
  (build-polygon (:points (parse-input "example.txt"))))

(defn border-clear? [outside points]
  (not-any? outside points))

(defn inside? [{:keys [x->idx y->idx outside]} [x1 y1] [x2 y2]]
  (let [ix1 (x->idx x1)
        ix2 (x->idx x2)
        iy1 (y->idx y1)
        iy2 (y->idx y2)
        xmin (min ix1 ix2)
        xmax (max ix1 ix2)
        ymin (min iy1 iy2)
        ymax (max iy1 iy2)]
    (and (border-clear? outside (map #(vector % ymin) (range xmin (inc xmax))))
         (border-clear? outside (map #(vector % ymax) (range xmin (inc xmax))))
         (border-clear? outside (map #(vector xmin %) (range ymin (inc ymax))))
         (border-clear? outside (map #(vector xmax %) (range ymin (inc ymax)))))))

(defn solve-part2 [path]
  (let [{:keys [points]} (parse-input path)
        polygon (build-polygon points)
        candidates (sort-by first >
                            (for [i (range (count points))
                                  j (range (inc i) (count points))]
                              [(rect-area (points i) (points j))
                               (points i)
                               (points j)]))]
    (some (fn [[area a b]]
            (when (inside? polygon a b)
              area))
          candidates)))

(comment
  (solve-part2 "example.txt"))

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 50 (solve-part1 example-file)))
    (assert (= 24 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
