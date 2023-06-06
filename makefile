.PHONY: up down docs

up:
	docker compose up -d --build

down: 
	docker compose down --remove-orphans

docs:
	pandoc -s -o docs/design_document.pdf docs/design_document.doc.md --resource-path=docs --toc
