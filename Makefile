# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

IMAGE= sbelgard/jagger:docker.hub
DIGEST=sha256:d00509c9b9befff4e941cabb62be2431cecad7d02e57b5eebc31c1e538449c4a

default: help

.PHONY: all
all: build run keygen sign verify sbom ## All Run all targets

build: ## Build Artifact
	docker build . -t ${IMAGE}

run: ## Run Artifact
	docker run -d -p 8084:80 --name jagger ${IMAGE} 

keygen: ## Generate cosign keypair
	COSIGN_PASSWORD=password ~/go/bin/cosign generate-key-pair

sign: ## Create attestation
	COSIGN_PASSWORD=password ~/go/bin/cosign sign --key ./cosign.key ${IMAGE}@${DIGEST}

verify: ## Create attestation
	COSIGN_PASSWORD=password ~/go/bin/cosign verify --key ./cosign.pub ${IMAGE} | jq .

sbom: ## ADDED BY SCOTT
	docker sbom ${IMAGE} > sbom.spdx
	COSIGN_PASSWORD=password ~/go/bin/cosign attest --predicate ./sbom.spdx --key ./cosign.key ${IMAGE} 
	~/go/bin/cosign verify-attestation ${IMAGE} --key cosign.pub | jq .


clean: ## Clean the workspace
	rm -rf cosign.*
	rm -rf sbom.spdx

help: ## Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST) | sort
