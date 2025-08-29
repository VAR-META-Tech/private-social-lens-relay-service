# Dfusion AI Indexer - Docker Management

.PHONY: help dev dev-full test ci up down clean logs wait-services

help: ## Show this help message
	@echo "Dfusion AI Indexer - Docker Commands"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Start all services for development
	@echo "🚀 Starting development environment..."
	@if [ "$$(uname -m)" = "arm64" ] && [ "$$(uname -s)" = "Darwin" ]; then \
		echo "📱 Detected Apple Silicon, using linux/amd64 platform..."; \
		DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose up -d; \
	else \
		docker-compose up -d; \
	fi
	@echo "✅ Services started!"
	@echo "📊 Qdrant UI: http://localhost:6333/dashboard"
	@echo "📧 MailDev UI: http://localhost:1080"
	@echo "🤖 Ollama API: http://localhost:11434"
	@echo "🗄️ Adminer: http://localhost:8080"

dev: up ## Alias for up command
	@echo "🔧 Development environment ready!"

test: ## Run tests with test environment
	@echo "🧪 Starting test environment..."
	@if [ "$$(uname -m)" = "arm64" ] && [ "$$(uname -s)" = "Darwin" ]; then \
		echo "📱 Detected Apple Silicon, using linux/amd64 platform..."; \
		DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose -f docker-compose.relational.test.yaml up -d; \
	else \
		docker-compose -f docker-compose.relational.test.yaml up -d; \
	fi
	@sleep 15
	@echo "🧪 Running tests..."
	npm run test:e2e
	@echo "🛑 Stopping test environment..."
	docker-compose -f docker-compose.relational.test.yaml down

ci: ## Run full CI pipeline with e2e tests
	@echo "🚀 Starting CI pipeline..."
	@if [ "$$(uname -m)" = "arm64" ] && [ "$$(uname -s)" = "Darwin" ]; then \
		echo "📱 Detected Apple Silicon, using linux/amd64 platform..."; \
		DOCKER_DEFAULT_PLATFORM=linux/amd64 docker compose -f docker-compose.relational.ci.yaml --env-file env-example-relational -p ci-relational up --build --exit-code-from api; \
	else \
		docker compose -f docker-compose.relational.ci.yaml --env-file env-example-relational -p ci-relational up --build --exit-code-from api; \
	fi

ci-start: ## Start CI environment only
	@echo "🚀 Starting CI environment..."
	@if [ "$$(uname -m)" = "arm64" ] && [ "$$(uname -s)" = "Darwin" ]; then \
		echo "📱 Detected Apple Silicon, using linux/amd64 platform..."; \
		DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose -f docker-compose.relational.ci.yaml up -d; \
	else \
		docker-compose -f docker-compose.relational.ci.yaml up -d; \
	fi
	@echo "✅ CI environment ready!"

down: ## Stop all services
	@echo "🛑 Stopping all services..."
	docker-compose down
	docker-compose -f docker-compose.relational.test.yaml down 2>/dev/null || true
	docker-compose -f docker-compose.relational.ci.yaml down 2>/dev/null || true
	@echo "✅ All services stopped"

clean: ## Stop and remove all containers, volumes, and networks
	@echo "🧹 Cleaning up all Docker resources..."
	docker-compose down -v --remove-orphans
	docker-compose -f docker-compose.relational.test.yaml down -v --remove-orphans 2>/dev/null || true
	docker-compose -f docker-compose.relational.ci.yaml down -v --remove-orphans 2>/dev/null || true
	@echo "✅ Cleanup complete"

logs: ## Show logs for all services
	docker-compose logs -f

logs-ollama: ## Show Ollama logs
	docker-compose logs -f ollama

logs-qdrant: ## Show Qdrant logs
	docker-compose logs -f qdrant

logs-api: ## Show API logs
	docker-compose logs -f api

status: ## Show status of all services
	@echo "📋 Service Status:"
	docker-compose ps

wait-services: ## Wait for all services to be ready
	@echo "⏳ Waiting for services to be ready..."
	@echo "Waiting for PostgreSQL..."
	@./wait-for-it.sh localhost:5432 -t 60
	@echo "Waiting for MailDev..."
	@./wait-for-it.sh localhost:1080 -t 60
	@echo "Waiting for Qdrant..."
	@./wait-for-it.sh localhost:6333 -t 60
	@echo "Waiting for Ollama..."
	@./wait-for-it.sh localhost:11434 -t 60
	@make setup-ollama
	@echo "✅ All services ready!"

dev-full: ## Full development setup with service waiting
	@echo "🚀 Starting full development environment..."
	@make up
	@make wait-services
	@echo "🔧 Running migrations and seeds..."
	@npm run migration:run
	@npm run seed:run:relational
	@echo "🎉 Development environment fully ready!"

# Default target
.DEFAULT_GOAL := help