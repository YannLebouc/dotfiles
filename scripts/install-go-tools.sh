#!/usr/bin/env bash
set -e

echo "Installing Go development tools..."

go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/nametake/golangci-lint-langserver@latest
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

echo "Go tools installed."
