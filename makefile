.PHONY: up down docs

up:
	docker compose up -d --build

down: 
	docker compose down --remove-orphans

docs:
	$(foreach file, $(wildcard docs/*.doc.md), pandoc -s -o $(file:.doc.md=.pdf) $(file) --resource-path=docs --toc;)
