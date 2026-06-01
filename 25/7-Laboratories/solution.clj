#!/usr/bin/env bb

(require '[clojure.string :as str])

(def ^:private base-dir
  (-> (or *file* ".")
      java.io.File.
      .getAbsoluteFile
      .getParent))

(comment
  base-dir)

(defn resolve-path [filename]
  (str (java.io.File. base-dir filename)))

(comment
  (resolve-path "example.txt"))

(defn parse-line [line]
  (keep-indexed #(when (= \^ %2) %1) line))

(comment
  (parse-line ".........^.......")
  (parse-line ".....^.....^....."))

(defn parse-input [path]
  (let [[beam-line & lines] (-> path slurp str/trimr str/split-lines)]
    {:beam (str/index-of beam-line \S)
     :width (count beam-line)
     :splitter-lines (map parse-line lines)}))

(comment
  (parse-input "example.txt"))

(defn step
  [{:keys [beams splits] :as acc} splitter prev-beams width]
  (let [conj-limit (fn [set key]
                     (if (and (>= key 0) (< key width))
                       (conj set key)
                       set))]
    (if (prev-beams splitter)
      {:beams (-> beams
                  (disj splitter)
                  (conj-limit (inc splitter))
                  (conj-limit (dec splitter)))
       :splits (inc splits)}
      acc)))

(comment
  (step {:beams #{7} :splits 0} 7 #{7} 15)
  )

(defn line-step [prev-acc splitters width]
  (reduce #(step %1 %2 (:beams prev-acc) width)
          prev-acc
          splitters))

(comment
  (line-step {:beams #{7} :splits 0} '(7) 15)
  (line-step {:beams #{7} :splits 0} '() 15)
  )

(defn solve-part1 [path]
  (let [{:keys [beam width splitter-lines]} (parse-input path)]
    (:splits (reduce #(line-step %1 %2 width)
                     {:beams #{beam}
                      :splits 0}
                     splitter-lines))))

(comment
  (solve-part1 "example.txt")
  )

(defn line-step2 [dp splitters width]
  (let [splitter-set (set splitters)]
    (for [i (range width)]
      (if (splitter-set i) 0
          (+ (if (splitter-set (dec i)) (nth dp (dec i)) 0)
             (if (splitter-set (inc i)) (nth dp (inc i)) 0)
             (nth dp i))))))

(defn solve-part2 [path]
  (let [{:keys [beam width splitter-lines]} (parse-input path)
        dp (assoc (vec (repeat width 0)) beam 1)]
    (reduce + (reduce #(line-step2 %1 %2 width)
             dp
             splitter-lines))))

(comment
  (solve-part2 "example.txt")
  )

(defn -main []
  (let [example-file (resolve-path "example.txt")
        input-file (resolve-path "input.txt")]
    (assert (= 21 (solve-part1 example-file)))
    (assert (= 40 (solve-part2 example-file)))
    (println "Part 1 - Solution:" (solve-part1 input-file))
    (println "Part 2 - Solution:" (solve-part2 input-file))))

(-main)
