# Help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ## Lint check all proto files
	@docker run -it -v $(PWD):/work uber/prototool:1.8.1 prototool format proto/ -d

fmt: ## Format all proto files
	@docker run -it -v $(PWD):/work uber/prototool:1.8.1 prototool format proto/ -w

build-go: ## Build the go sdk from the proto files
	@./tool/build-go.sh

### ---- Non local commands below here ----

push-go:
	@./tool/push-go.sh

cleanup:
	@./tool/cleanup-go.sh
