FROM alpine:3.22

# ffmpeg para reenviar los streams; tini como PID 1 para propagar señales y limpiar procesos hijos
RUN apk add --no-cache ffmpeg tini \
 && addgroup -S -g 10001 relay && adduser -S -u 10001 -G relay relay

COPY --chmod=755 relay.sh /usr/local/bin/relay.sh

# UID numérico: permite a Kubernetes verificar runAsNonRoot sin resolver nombres
USER 10001:10001
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/relay.sh"]
