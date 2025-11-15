COMPOSE_FILE := srcs/docker-compose.yml
WORDPRESS_DATA_DIR := /home/izma/isallali/data/wordpress
MARIADB_DATA_DIR := /home/izma/isallali/data/mariadb

.PHONY: up down build clean ps logs ensure-dirs

up: ensure-dirs ## Build and start the stack in detached mode
	docker compose -f $(COMPOSE_FILE) up -d

ensure-dirs:
	mkdir -p $(WORDPRESS_DATA_DIR) $(MARIADB_DATA_DIR)

down: ## Stop containers without removing volumes
	docker compose -f $(COMPOSE_FILE) down

build: ## Rebuild images without using cache
	docker compose -f $(COMPOSE_FILE) build --no-cache

clean: ## Remove containers, networks, and named volumes
	docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans

ps: ## List running services
	docker compose -f $(COMPOSE_FILE) ps

logs: ## Follow logs for all services
	docker compose -f $(COMPOSE_FILE) logs -f
