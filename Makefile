# Help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Lint check all proto files
	@docker run -it -v $(PWD):/work uber/prototool:1.8.1 prototool format proto/ -d

fmt: ## Format all proto files
	@docker run -it -v $(PWD):/work uber/prototool:1.8.1 prototool format proto/ -w
