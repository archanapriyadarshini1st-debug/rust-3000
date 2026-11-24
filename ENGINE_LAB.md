# Engine Lab: measured path toward 3100

This document records the development baseline and validation rules. **3100 is a target, not a measured result.** Ratings are meaningful only when tied to an opponent pool, time control, hardware, hash size, thread count, and statistical interval.

## Current implementation snapshot

The engine is an original Rust UCI implementation with copy-make bitboards, generated magic slider attacks, PVS/alpha-beta search, iterative deepening, aspiration windows, a transposition table, move histories, killer/counter moves, SEE, LMR, LMP, reverse-futility pruning, null-move pruning, and a custom 768-feature / 128-hidden NNUE with an incrementally updated accumulator.

Stockfish 19 can be used as a match opponent or as a source of labelled positions. Do not import Stockfish source code or its network weights into this repository. Any future model must be trained from data with documented provenance and remain compatible with this engine's own feature and serialization format.

## Fixes in phase 1

- FEN rank separators now reject incomplete ranks instead of silently accepting malformed board layouts.
- NNUE parsing checks the serialized format version.
- The x86-64 AVX2 dispatch now executes a vectorized output layer; a test compares it against the scalar evaluator on a deterministic legal playout.
- Hash sizing uses the real 16-byte entry size and selects the largest fitting power-of-two table without exceeding the requested MiB budget.
- CI builds and tests the engine on Linux and Windows.

## Reproducible local checks

Run from the repository root:

```sh
cargo test --all-targets
cargo build --release
cargo run --release -- bench 10
```

The built-in `bench` command is a search-throughput regression check (nodes and NPS), not an Elo measurement.

## Stockfish 19 match protocol

Use the official Stockfish 19 release binary, not a development snapshot. Keep both engines on the same machine and use the same wall-clock time control and Hash size. Run one thread per engine because this implementation currently exposes a single search thread. Do not set Stockfish skill or Elo-limit options. Use a diverse, shuffled EPD/PGN opening suite and `-repeat` so each opening is played with both colors. Retain the PGNs and logs for every run.

A starting runner is provided at `scripts/match_sf19.sh`. Defaults are one concurrent game, 60+0.6 time control, equal 256 MiB Hash, and an SPRT with hypotheses 0 Elo versus +10 Elo. Set `ENGINE`, `STOCKFISH19`, and `OPENINGS` to local paths before running. The script does not include either engine or an opening book.

Example:

```sh
ENGINE=./target/release/chess-rust-engine \
STOCKFISH19=./stockfish \
OPENINGS=./openings.epd \
FASTCHESS=./fastchess \
./scripts/match_sf19.sh
```

An SPRT result applies only to that tested candidate, baseline, and setup. A single short match is not a reliable global rating. For a rating estimate, repeat across opening sets and time controls, retain all PGNs, and report score, Elo estimate, confidence interval, game count, hardware, versions, and time control.

## Strength-development loop

1. **Correctness gate:** perft, move-generation differential checks, FEN/UCI validation, NNUE scalar-vs-SIMD parity, and deterministic search regression.
2. **Throughput gate:** fixed-position node/NPS bench on the same machine, with identical compiler flags and TT size.
3. **Tactical gate:** tactical EPD suites and curated positions, tracking solved/failed positions and best-move stability.
4. **Evaluation gate:** generate diverse legal-game positions; audit duplicate rate, game phase, material balance, result quality, and side-to-move convention before training.
5. **Training gate:** keep train/validation/test games disjoint; compare quantized inference against floating-point and scalar oracles; version every network with a checksum and data manifest.
6. **Strength gate:** test one change at a time in color-paired games. Keep a patch only after statistically significant gains without unacceptable regressions.

Potential future work, ordered by impact and risk: SIMD accumulator updates; expand and retrain the original NNUE with audited self-play/teacher labels; test correction history and other search changes behind SPRT-tested parameter switches; add multi-threaded Lazy SMP with single-thread fallback; then tune parameters with SPSA or an equivalent reproducible optimizer.

## Research references

- Stockfish 19 release notes: https://stockfishchess.org/blog/2026/stockfish-19/
- Stockfish NNUE technical documentation: https://official-stockfish.github.io/docs/nnue-pytorch-wiki/docs/nnue.html
- Fishtest methodology: https://official-stockfish.github.io/docs/fishtest-wiki/Home.html
- Fastchess match runner: https://github.com/Disservin/fastchess

The central lesson is methodological: architecture and training quality matter, but engine improvements must be established by paired games and statistical testing. A plausible heuristic without measurement can weaken an engine.
