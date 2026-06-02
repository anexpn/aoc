#!/usr/bin/env bb

(ns solution2
  (:require [clojure.java.io :as io]
            [clojure.string :as str]))

(def ^:private base-dir
  (-> (or *file* ".")
      io/file
      .getAbsoluteFile
      .getParent))

(defn resolve-path [filename]
  (str (io/file base-dir filename)))

(defn parse-long* [s]
  (Long/parseLong s))

(defn parse-line [line]
  (mapv parse-long* (str/split line #",")))

(defn parse-input [path]
  (->> path
       slurp
       str/trimr
       str/split-lines
       (mapv parse-line)))

(defn sq [x]
  (* x x))

(defn dist2 [a b]
  (reduce + (map (comp sq -) a b)))

(defn all-edges [points]
  (sort-by first
           (for [i (range (count points))
                 j (range (inc i) (count points))]
             [(dist2 (points i) (points j)) i j])))

(defn make-union-find [n]
  {:parent (vec (range n))
   :size (vec (repeat n 1))})

(defn find-root [{:keys [parent]} x]
  (loop [node x]
    (let [p (parent node)]
      (if (= node p)
        node
        (recur p)))))

(defn connected? [uf a b]
  (= (find-root uf a) (find-root uf b)))

(defn union [uf a b]
  (let [ra (find-root uf a)
        rb (find-root uf b)]
    (if (= ra rb)
      uf
      (let [sa (get-in uf [:size ra])
            sb (get-in uf [:size rb])
            [root child] (if (< sa sb) [rb ra] [ra rb])]
        (-> uf
            (assoc-in [:parent child] root)
            (update-in [:size root] + (get-in uf [:size child])))))))

(defn top3-size-product [uf]
  (->> (keep-indexed (fn [idx parent]
                       (when (= idx parent)
                         (get-in uf [:size idx])))
                     (:parent uf))
       (sort >)
       (take 3)
       (reduce *)))

(defn solve-part1 [path edge-limit]
  (let [points (parse-input path)
        edges (all-edges points)
        uf0 (make-union-find (count points))]
    (->> edges
         (take edge-limit)
         (reduce (fn [uf [_ a b]]
                   (if (connected? uf a b)
                     uf
                     (union uf a b)))
                 uf0)
         top3-size-product)))

(defn solve-part2 [path]
  (let [points (parse-input path)
        uf0 (make-union-find (count points))]
    (:last-product
     (reduce (fn [{:keys [uf] :as state} [_ a b]]
               (if (connected? uf a b)
                 state
                 {:uf (union uf a b)
                  :last-product (* (first (points a))
                                   (first (points b)))}))
             {:uf uf0
              :last-product 0}
             (all-edges points)))))

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 40 (solve-part1 example-file 10)))
    (assert (= 25272 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file 1000))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
