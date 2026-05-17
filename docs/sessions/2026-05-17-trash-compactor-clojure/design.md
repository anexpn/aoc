# Trash Compactor Clojure Solution

## Goal

Add a standalone Clojure solution for `25/6-Trash-Compactor` without introducing repo-level Clojure setup.

## Approach

Use direct text scanning instead of a grammar parser.

- Part 1 parses each number row with `\d+` and the operator row with `[+*]`, then applies each operator column-wise across the rows.
- Part 2 treats each operator character position as the start of a column window. For each character column in that window, it reads the digits stacked vertically across the number rows, forms a number, and then applies the operator to the resulting sequence.

## Runtime

The script resolves `example.txt` and `input.txt` relative to `solution.clj`, so it can be run from the repo root with:

```bash
clojure 25/6-Trash-Compactor/solution.clj
```

## Validation

The script asserts the known example answers before printing the input answers.
