#!/usr/bin/env clojure

(require '[clojure.string :as str])

(def ^:private base-dir
  (-> (or *file* ".")
      java.io.File.
      .getAbsoluteFile
      .getParent))

(defn resolve-path [filename]
  (str (java.io.File. base-dir filename)))

(defn parse-long* [s]
  (Long/parseLong s))

(defn parse-input [path]
  (let [lines (-> path slurp str/trimr str/split-lines)]
    {:number-rows (vec (butlast lines))
     :ops-line (last lines)}))

(defn eval-op [op nums]
  (case op
    \* (reduce * 1 nums)
    \+ (reduce + 0 nums)))

(defn solve-part1 [path]
  (let [{:keys [number-rows ops-line]} (parse-input path)
        rows (mapv (fn [line] (mapv parse-long* (re-seq #"\d+" line))) number-rows)
        ops (mapv first (re-seq #"[+*]" ops-line))]
    (reduce +
            (map-indexed
             (fn [idx op]
               (eval-op op (map #(nth % idx) rows)))
             ops))))

(defn op-columns [ops-line]
  (keep-indexed
   (fn [idx ch]
     (when (#{\* \+} ch)
       {:col idx :op ch}))
   ops-line))

(defn char-at [^String s idx]
  (when (< idx (.length s))
    (.charAt s idx)))

(defn vertical-number [rows col]
  (let [digits (keep (fn [^String row]
                       (let [ch (char-at row col)]
                         (when (and ch (Character/isDigit ch))
                           ch)))
                     rows)]
    (when (seq digits)
      (parse-long* (apply str digits)))))

(defn solve-part2 [path]
  (let [{:keys [number-rows ops-line]} (parse-input path)
        ops (vec (op-columns ops-line))
        max-col (reduce max (count ops-line) (map count number-rows))]
    (reduce +
            (map-indexed
             (fn [idx {:keys [col op]}]
               (let [end (if-let [next-op (nth ops (inc idx) nil)]
                           (:col next-op)
                           max-col)
                     nums (keep #(vertical-number number-rows %) (range col end))]
                 (eval-op op nums)))
             ops))))

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 4277556 (solve-part1 example-file)))
    (assert (= 3263827 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
