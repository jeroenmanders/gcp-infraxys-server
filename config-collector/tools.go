// This file is only included here so dependencies that are not defined
//	in other .go files are automatically installed.
//go:build tools
// +build tools

package main

import (
	_ "github.com/golangci/golangci-lint/cmd/golangci-lint"
)
