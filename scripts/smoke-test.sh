#!/bin/sh
# Prueba de punta a punta del pipeline (la usa CI y sirve en local):
#   1. publica una señal de prueba en SRS
#   2. verifica que SRS la recibe (API)
#   3. verifica que el relay la entregó a OvenMediaEngine (playlist LL-HLS)
# Requiere el stack levantado: docker compose up -d --build
set -eu

STREAM="smoke$$"
HOST="${HOST:-localhost}"
TIMEOUT="${TIMEOUT:-120}"

cleanup() {
  kill "$PUB" 2>/dev/null || true
  docker compose up -d --no-deps relay >/dev/null 2>&1 || true   # relay vuelve a STREAMS del .env
}

wait_for() {
  desc="$1"; shift
  elapsed=0
  printf '⏳ %s ' "$desc"
  until "$@" >/dev/null 2>&1; do
    elapsed=$((elapsed + 3))
    if [ "$elapsed" -ge "$TIMEOUT" ]; then printf '\n❌ %s: no ocurrió en %ss\n' "$desc" "$TIMEOUT"; return 1; fi
    printf '.'; sleep 3
  done
  printf ' ✅ (%ss)\n' "$elapsed"
}

srs_has_stream() { curl -fsS "http://$HOST:1985/api/v1/streams/" | grep -q "\"$STREAM\""; }
ome_has_playlist() { curl -fsS "http://$HOST:3333/app/$STREAM/llhls.m3u8" | grep -q '#EXTM3U'; }

echo "▶ Reiniciando relay para el stream de prueba '$STREAM'"
STREAMS="$STREAM" docker compose up -d --no-deps relay

echo "▶ Publicando señal de prueba"
./scripts/test-stream.sh "$STREAM" "$TIMEOUT" >/tmp/smoke-publisher.log 2>&1 &
PUB=$!
trap cleanup EXIT

wait_for "SRS recibe el stream (RTMP)" srs_has_stream
wait_for "OvenMediaEngine publica LL-HLS (via relay)" ome_has_playlist

echo "✅ Pipeline OK: OBS/RTMP -> SRS -> relay -> OME -> WebRTC/LL-HLS"
