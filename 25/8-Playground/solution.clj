#!/usr/bin/env bb

(ns solution
  (:require [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.math :as math]))

(def ^:private base-dir
  (-> (or *file* ".")
      io/file
      .getAbsoluteFile
      .getParent))

(defn resolve-path [filename]
  (str (io/file base-dir filename)))

(defn parse-line [line]
  (map Long/parseLong (str/split line #",")))

(comment
  (parse-line "162,817,812")
  )

(defn parse-input [path]
  (let [lines (-> path slurp str/trimr str/split-lines)]
    {:points (mapv parse-line lines)}))

(comment
  (parse-input "example.txt")
  )

(defn calc-dists [points]
  (for [[i a] (map-indexed vector points)
        [j b] (map-indexed vector points)
        :when (< i j)]
    [(math/sqrt (reduce + (map #(math/pow (- %1 %2) 2) a b))) [i j]]))

(comment
  (def ps (:points (parse-input "example.txt")))
  ps
  (calc-dists ps)
  (map-indexed vector ps)
  (calc-dists (:points (parse-input "example.txt")))
  )

(defn prod-of-max-3 [sz]
  (reduce * (take 3 (sort > sz))))

(comment
  (prod-of-max-3 [8 11 9 2 1 4 5])
  )

(defn connected? [uf a b]
  (= (find uf a) (find uf b)))

(defn find [uf x]
  (when-let [p (get-in uf [:g x])]
    (if (= p x)
      p
      (recur uf p))))

(comment
  (def uf {:g [0 0 0 0 4 4 4 4]
           :sz [4 4 4 4 4 4 4 4]})
  (find uf 3)
  (find uf 7)
  (find uf 100)
  )

(defn union [{:keys [g sz] :as uf} a b]
  (let [pa (find uf a)
        pb (find uf b)
        sza (get sz pa)
        szb (get sz pb)]
    (cond (= pa pb) uf
          (< sza szb) (-> uf
                          (update :g assoc pa pb)
                          (update :sz assoc pb (+ sza szb)))
          :else (-> uf
                    (update :g assoc pb pa)
                    (update :sz assoc pa (+ sza szb))))))

(comment
  (def uf {:g (vec (range 10))
           :sz (vec (repeat 10 1))})
  (find uf 0)
  (find uf 1)
  (get (:sz uf) (find uf 0))
  (union uf 0 1)
  )

(defn solve-part1 [path n]
  (let [{:keys [points]} (parse-input path)
        c (count points)
        dists (calc-dists points)
        pq (java.util.PriorityQueue. dists)]
    (loop [uf {:g (vec (range c))
               :sz (vec (repeat c 1))}
           i 0]
      (if (>= i n)
        (prod-of-max-3 (:sz uf))
        (if-let [[dist [a b]] (.poll pq)]
          (if (connected? uf a b)
            (recur uf (inc i))
            (recur (union uf a b) (inc i))))))))

(comment
  (solve-part1 "example.txt" 10)
  )

(defn solve-part2 [path]
  (let [{:keys [points]} (parse-input path)
        c (count points)
        dists (calc-dists points)
        pq (java.util.PriorityQueue. dists)]
    (loop [uf {:g (vec (range c))
               :sz (vec (repeat c 1))}
           last-res 0]
      (if-let [[dist [a b]] (.poll pq)]
        (if (connected? uf a b)
          (recur uf last-res)
          (recur (union uf a b) (* (first (get points a))
                                   (first (get points b)))))
        last-res))
    ))

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 40 (solve-part1 example-file 10)))
    (assert (= 25272 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file 1000))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
