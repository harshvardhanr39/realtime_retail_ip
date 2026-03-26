.PHONY: setup run test

setup:
	@echo "Setting up project..."
	pip install -r requirements.txt

run:
	@echo "Running application..."
	python main.py

test:
	@echo "Running tests..."
	pytest tests/

.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  make setup - Install dependencies"
	@echo "  make run   - Run the application"
	@echo "  make test  - Run tests"