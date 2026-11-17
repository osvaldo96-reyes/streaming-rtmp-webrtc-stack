#!/bin/sh
# Reenvía cada stream de SRS a OvenMediaEngine sin recodificar (-c copy).
# Un proceso por stream; si la fuente se cae o aún no existe, reintenta solo.
#
# Variables:
#   SOURCE_BASE    origen, p. ej. rtmp://srs:1935/live
#   DEST_BASE      destino, p. ej. rtmp://ome:1935/app
#   STREAMS        lista separada por comas, p. ej. "sala1,sala2"
#   RETRY_SECONDS  espera entre reintentos (por defecto 3)
set -eu

: "${SOURCE_BASE:?Define SOURCE_BASE}"
: "${DEST_BASE:?Define DEST_BASE}"
STREAMS="${STREAMS:-demo}"
RETRY_SECONDS="${RETRY_SECONDS:-3}"

log() { printf '%s [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2"; }

relay_loop() {
  name="$1"
  while :; do
    log "$name" "relay $SOURCE_BASE/$name -> $DEST_BASE/$name"
    ffmpeg -hide_banner -loglevel warning -nostdin \
      -i "$SOURCE_BASE/$name" -c copy -f flv "$DEST_BASE/$name" || true
    log "$name" "fuente terminada o no disponible; reintento en ${RETRY_SECONDS}s"
    sleep "$RETRY_SECONDS"
  done
}

for name in $(printf '%s' "$STREAMS" | tr ',' ' '); do
  relay_loop "$name" &
done

log main "streams activos: $STREAMS"
wait
