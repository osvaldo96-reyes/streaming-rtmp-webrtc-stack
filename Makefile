.DEFAULT_GOAL := help
.PHONY: help up down logs ps test-stream smoke lint

help: ## Muestra esta ayuda
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

up: ## Levanta el stack completo
	docker compose up -d --build
	@echo "Reproductor: http://localhost:$${PLAYER_PORT:-8088}"

down: ## Detiene y elimina los contenedores
	docker compose down

logs: ## Sigue los logs de todos los servicios
	docker compose logs -f --tail=50

ps: ## Estado de los servicios
	docker compose ps

test-stream: ## Publica barras de color en el stream "demo" (Ctrl+C para parar)
	./scripts/test-stream.sh demo

smoke: ## Prueba de punta a punta (la misma que corre CI)
	./scripts/smoke-test.sh

lint: ## Lint de Dockerfile, shell y compose (requiere hadolint y shellcheck)
	hadolint relay/Dockerfile
	shellcheck relay/relay.sh scripts/*.sh
	docker compose config -q
