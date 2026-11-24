#!/usr/bin/env bash
set -euo pipefail

: "${ENGINE:?Set ENGINE to this engine's release binary}"
: "${STOCKFISH19:?Set STOCKFISH19 to the official Stockfish 19 binary}"
: "${OPENINGS:?Set OPENINGS to a diverse EPD opening suite}"

FASTCHESS="${FASTCHESS:-fastchess}"
HASH_MB="${HASH_MB:-256}"
TC="${TC:-60+0.6}"
ROUNDS="${ROUNDS:-100000}"
CONCURRENCY="${CONCURRENCY:-1}"
OUTPUT="${OUTPUT:-sf19-match.pgn}"
LOG="${LOG:-sf19-match.log}"

"${FASTCHESS}" \
  -engine cmd="${ENGINE}" name=rust-3000 option.Hash="${HASH_MB}" option.Threads=1 \
  -engine cmd="${STOCKFISH19}" name=Stockfish-19 option.Hash="${HASH_MB}" option.Threads=1 \
  -each proto=uci tc="${TC}" \
  -openings file="${OPENINGS}" format=epd order=random \
  -repeat -rounds "${ROUNDS}" -concurrency "${CONCURRENCY}" \
  -resign movecount=3 score=600 \
  -draw movenumber=34 movecount=8 score=20 \
  -sprt elo0=0 elo1=10 alpha=0.05 beta=0.05 \
  -pgnout file="${OUTPUT}" notation=san nodes=true \
  -log file="${LOG}" level=info
