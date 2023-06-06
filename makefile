.PHONY: up down docs

up:
	docker compose up -d --build

down: 
	docker compose down --remove-orphans

docs:
	pandoc -s -o docs/paper.pdf docs/paper.doc.md --resource-path=docs --toc
