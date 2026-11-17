FROM alpine:3.22

# ffmpeg para reenviar los streams; tini como PID 1 para propagar señales y limpiar procesos hijos
RUN apk add --no-cache ffmpeg tini \
 && addgroup -S relay && adduser -S -G relay relay

COPY --chmod=755 relay.sh /usr/local/bin/relay.sh

USER relay
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/relay.sh"]
