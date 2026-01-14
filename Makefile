COMPOSE_FILE := srcs/docker-compose.yml
DATA_ROOT ?= $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_ROOT)/wordpress
MARIADB_DATA_DIR := $(DATA_ROOT)/mariadb
REDIS_DATA_DIR := $(DATA_ROOT)/redis

.PHONY: up down build clean reset ps logs ensure-dirs

up: ensure-dirs ## Build and start the stack in detached mode
	docker compose --project-directory srcs -f $(COMPOSE_FILE) up -d --build

ensure-dirs:
	mkdir -p $(WORDPRESS_DATA_DIR) $(MARIADB_DATA_DIR) $(REDIS_DATA_DIR)

down: ## Stop containers without removing volumes
	docker compose --project-directory srcs -f $(COMPOSE_FILE) down

build: ## Rebuild images without using cache
	docker compose --project-directory srcs -f $(COMPOSE_FILE) build --no-cache

clean: ## Remove containers, networks, and named volumes
	docker compose --project-directory srcs -f $(COMPOSE_FILE) down --volumes --remove-orphans

reset: clean ## Full reset (wipe bind-mounted data)
	rm -rf $(WORDPRESS_DATA_DIR) $(MARIADB_DATA_DIR)
	mkdir -p $(WORDPRESS_DATA_DIR) $(MARIADB_DATA_DIR)

ps: ## List running services
	docker compose --project-directory srcs -f $(COMPOSE_FILE) ps

logs: ## Follow logs for all services
	docker compose --project-directory srcs -f $(COMPOSE_FILE) logs -f
