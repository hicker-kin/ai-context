---
name: go-import
description: Use when writing or reviewing Go imports. Enforces import grouping and ordering from ai_go/v1/rules/code_style.md: standard library, third-party, second-party, local module, with blank lines between groups and goimports/gofmt alignment.
---

# Go Import Sorting

Summarizes and applies the import sorting rule from `ai_go/v1/rules/code_style.md`.

## When to apply

Apply this skill when:

- Adding or editing any Go `import` block
- Reviewing pull requests for Go style compliance
- Refactoring package paths or moving files across modules
- Running formatting checks before commit

## Mandatory rule

Go imports MUST be grouped with blank lines between groups, in this order:

1. Standard library
2. Third-party
3. Second-party (same organization, reusable SDK/shared libs)
4. Local package (current `go.mod` module and its internal packages)

## Example structure

```go
import (
    "errors"
    "fmt"

    "github.com/acme/foo"

    "mycorp/sdk/bar"

    "mycorp/app/internal/biz"
)
```

## Execution checklist

- Ensure all imports are in exactly one of the four groups.
- Keep groups in the required order.
- Add one blank line between adjacent groups.
- Remove unused imports.
- Run `goimports` first, then `gofmt -s` if needed.

## Notes

- If there is no second-party package in a file, omit that group; do not keep empty separators.
- If there is no local package import, keep only existing groups in order.
- In single-import files, no grouping line is needed.
