SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

-include .env

LINKERD_VERSION ?= stable-2.16
LINKERD_NAMESPACE ?= linkerd
VALUES_FILE := values/linkerd-values.yaml
KUBECONFIG ?= $(if $(wildcard .secrets/kubeconfig),$(abspath .secrets/kubeconfig),)

.PHONY: help
help:
	@echo 'linkerd — Ultralight service mesh (mTLS, retries/timeouts, golden signals)'
	@echo ''
	@echo '  make prerequisites  Check kubectl + linkerd CLI + cluster access'
	@echo '  make install        Pre-check + apply control plane from values + post-check'
	@echo '  make check          Full linkerd check suite'
	@echo '  make status         Control-plane pods and versions'
	@echo '  make validate       Static + live validation suite'
	@echo ''
	@echo '  make uninstall      Remove the control plane (destructive)'

export KUBECONFIG

.PHONY: prerequisites
prerequisites:
	@echo '=== Checking prerequisites ==='
	scripts/validate.sh --static-only

.PHONY: install
install:
	@echo "=== Installing Linkerd control plane ($(LINKERD_VERSION)) ==="
	LINKERD_VERSION=$(LINKERD_VERSION) LINKERD_NAMESPACE=$(LINKERD_NAMESPACE) VALUES_FILE=$(VALUES_FILE) scripts/install.sh

.PHONY: check
check:
	@echo '=== Running linkerd check ==='
	linkerd check --timeout 120s

.PHONY: status
status:
	@echo '=== Control-plane status ==='
	linkerd version
	kubectl -n $(LINKERD_NAMESPACE) get pods

.PHONY: validate
validate:
	@echo '=== Validating Linkerd ==='
	LINKERD_VERSION=$(LINKERD_VERSION) LINKERD_NAMESPACE=$(LINKERD_NAMESPACE) scripts/validate.sh

.PHONY: uninstall
uninstall:
	@echo '=== Removing Linkerd control plane (DESTRUCTIVE — meshed workloads keep proxies) ==='
	linkerd uninstall | kubectl delete -f -

.PHONY: clean
clean:
	@echo '=== Cleaning up local state ==='
	rm -f .env
	@echo 'Done.'
