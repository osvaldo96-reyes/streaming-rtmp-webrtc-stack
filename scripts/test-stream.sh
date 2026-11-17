#!/bin/sh
# Publica una señal de prueba (barras de color + tono) en SRS, como lo haría OBS.
# No requiere ffmpeg en el host: usa la imagen del relay.
#
# Uso: ./scripts/test-stream.sh [stream] [segundos]
set -eu
STREAM="${1:-demo}"
DURATION="${2:-0}"   # 0 = sin límite

LIMIT=""
[ "$DURATION" -gt 0 ] && LIMIT="-t $DURATION"

# shellcheck disable=SC2086  # LIMIT se expande en varias palabras a propósito
exec docker compose run --rm --no-deps --entrypoint ffmpeg relay \
  -hide_banner -loglevel warning -re \
  -f lavfi -i "testsrc2=size=1280x720:rate=30" \
  -f lavfi -i "sine=frequency=440:sample_rate=48000" \
  $LIMIT \
  -c:v libx264 -preset veryfast -tune zerolatency -pix_fmt yuv420p -g 60 -b:v 2500k \
  -c:a aac -b:a 128k \
  -f flv "rtmp://srs:1935/live/$STREAM"
