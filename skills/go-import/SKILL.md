---
name: go-import
description: "Use when writing or reviewing Go imports, especially when a repository has existing formatting automation or import-grouping conventions that must be preserved."
---

# Go Import Formatting

Keep import grouping aligned with repository automation first, generic formatting rules second.

## When to apply

- Adding or editing Go imports
- Reviewing Go import formatting
- Running formatting checks before commit

## Workflow

1. Inspect the repo for formatting/import automation before changing import order.
2. Prefer the repository's existing entrypoint exactly as defined, such as `Makefile`, `Taskfile`, `justfile`, scripts, or CI-documented commands.
3. If no repo automation exists, run formatting from the directory that contains the target `go.mod`. In multi-module repos, repeat the fallback commands per module instead of running once from the repository root.
4. If no repo automation exists and `gci` is installed, run `goimports -local $(go list -m) -w .` from the module root and then apply the 3-group `gci` layout shown below.
5. If no repo automation exists and `gci` is not installed, install it with `go install github.com/daixiang0/gci@latest` only when the environment and user permissions allow installation, then apply the same 3-group layout.
6. If installing `gci` is not possible, accept the `goimports -local $(go list -m)` result as the fallback instead of inventing a repo-wide custom grouping by hand.
7. Run `gofmt -s` afterward only if the repo or surrounding workflow expects it.
8. Avoid hand-sorting imports unless automation is unavailable and the fix is trivial.
9. Preserve existing non-default grouping only when the repository already enforces it.

## Discovery checklist

Before changing imports, check for any of the following:

- `Makefile`, `Taskfile`, or `justfile` formatting targets
- formatter scripts under `scripts/`, `hack/`, or similar repo utility directories
- CI config that runs `goimports`, `gci`, `golangci-lint`, or custom formatting commands
- existing Go files that already show a stable grouping pattern

If those sources disagree, follow the most explicit executable automation over prose documentation.

## Repository automation

Apply this layout only when the repo does not already define a different executable formatting command. The example assumes it runs from a Go module root; in multi-module repositories, run the same pattern separately inside each module.

```makefile
MODULE := $(shell go list -m)

.PHONY: fmt
fmt:
	goimports -local $(MODULE) -w .
	gci write --skip-generated \
		-s standard \
		-s default \
		-s "prefix($(MODULE))" \
		.
```

This example produces 3 groups:

1. Standard library
2. External packages outside the current module
3. Local packages whose path prefix matches `$(MODULE)`

If a repository already uses `gci` or another formatter with different sections, follow that configuration instead of normalizing back to the generic 3-group layout.

## Manual fallback rule

When manual judgment is needed and the repo does not define a different rule, keep imports in this order with one blank line between present groups:

1. Standard library
2. External packages, including third-party and shared organization packages outside the current module
3. Local packages whose path prefix exactly matches the current `go.mod` module value

Omit missing groups. Single-import files need no grouping blank line.

Only split shared organization packages into their own middle group when the repository already does that through formatter config or established file patterns.

## Common mistakes

- Treating shared organization packages as a separate default group when the repo does not enforce that split
- Reordering imports by eye after `goimports` or `gci` already produced a stable result
- Overriding repo automation because a generic style guide says something different
- Normalizing one file to a new grouping scheme without updating the repo's formatter config

For full usage examples, see [examples.md](examples.md).
