#!/usr/bin/env bb

(ns solution2
  (:require [clojure.java.io :as io]
            [clojure.set :as set]
            [clojure.string :as str]))

(def ^:private base-dir
  (-> (or *file* ".")
      io/file
      .getAbsoluteFile
      .getParent))

(defn resolve-path [filename]
  (str (io/file base-dir filename)))

(defn parse-line [line]
  (into #{} (keep-indexed #(when (= \^ %2) %1) line)))

(defn parse-input [path]
  (let [[beam-line & lines] (-> path slurp str/trimr str/split-lines)]
    {:beam (str/index-of beam-line \S)
     :width (count beam-line)
     :splitter-lines (mapv parse-line lines)}))

(defn neighbors [width i]
  (cond-> #{}
    (pos? i) (conj (dec i))
    (< i (dec width)) (conj (inc i))))

(defn row-step [{:keys [beams splits]} splitters width]
  (let [hits (set/intersection beams splitters)
        spawned (into #{} (mapcat #(neighbors width %) hits))]
    {:beams (into (set/difference beams hits) spawned)
     :splits (+ splits (count hits))}))

(defn solve-part1 [path]
  (let [{:keys [beam width splitter-lines]} (parse-input path)]
    (:splits
     (reduce #(row-step %1 %2 width)
             {:beams #{beam}
              :splits 0}
             splitter-lines))))

(defn splitter-contrib [dp splitters i]
  (if (splitters i) (get dp i 0) 0))

(defn row-step2 [dp splitters]
  (into []
        (map-indexed (fn [i beam-count]
                       (if (splitters i)
                         0
                         (+ beam-count
                            (splitter-contrib dp splitters (dec i))
                            (splitter-contrib dp splitters (inc i))))))
        dp))

(defn solve-part2 [path]
  (let [{:keys [beam width splitter-lines]} (parse-input path)
        initial-dp (assoc (vec (repeat width 0)) beam 1)
        final-dp (reduce row-step2 initial-dp splitter-lines)]
    (reduce + final-dp)))

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 21 (solve-part1 example-file)))
    (assert (= 40 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
