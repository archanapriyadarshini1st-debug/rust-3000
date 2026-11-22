# rust-3000

A **UCI chess engine** written in Rust. Clone it, build it, plug it into any UCI GUI (Arena, Cute Chess, Banksia, Nibbler, …) or talk to it over stdin.

This is the strongest *runnable* snapshot of [Chess-rust-engine](https://github.com/archanapriyadarshini1st-debug/Chess-rust-engine): G4 NNUE weights plus the search/time stack on `cp/stack-g4net`. Training, GitHub Actions, and experiment notes are **not** in this repo.

## Build

Needs a recent [Rust](https://rustup.rs/) toolchain.

```bash
git clone https://github.com/archanapriyadarshini1st-debug/rust-3000.git
cd rust-3000
cargo build --release
./target/release/chess-rust-engine
```

Or `make release`. For a CPU-native binary: `make native`.

## Use

The binary speaks UCI. Example:

```
uci
isready
ucinewgame
position startpos
go movetime 1000
```

Common options: `Hash` (MB), `Threads` (1 unless you built a SMP snapshot). The NNUE net is **embedded** (`nets/default.nnue`). Override with env `CRE_NNUE_FILE=/path/to/net.bin` if you want.

## Strength (honest)

Measured vs official Stockfish 19, 10+0.1, 1 thread, Hash=64, 100 games:

| opponent | score |
|---|---|
| SF19 `UCI_Elo 2900` | 63.0% |
| SF19 `UCI_Elo 3000` | 50.5% |

That is **not** a 3000 CCRL rating, and it is **not** 80% vs 3000. Source of the numbers: Chess-rust-engine Actions run 44984894349.

## License

[GPL-3.0-or-later](LICENSE). You may run, study, share, and modify it for any purpose, including commercial, as long as you keep the GPL terms (source with binaries, same license on derivatives).

Original engine code — not a fork of Stockfish or Reckless.
