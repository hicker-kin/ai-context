---
name: go-import
description: "Use when writing or reviewing Go imports. Enforces import grouping and ordering (standard library, third-party, second-party, local module) with blank lines between groups and goimports/gofmt alignment."
---

# Go Import Sorting

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

### Additional hard constraint for this skill

If you use this skill, you MUST keep **local package imports as the last group** (group 4). Do not place local packages into the second-party group even if they share the same organization prefix.

## What counts as “local package”

“Local package” means any import path whose prefix **exactly matches** the `module` path declared in `go.mod` (plus any subpackages under it).

Example `go.mod`:

```go
module github.com/mycorp/myapp
```

Then these are **local** (group 4):

```go
import (
    "github.com/mycorp/myapp/internal/biz"
    "github.com/mycorp/myapp/pkg/crypto"
)
```

And these are **not local** (they do NOT start with the exact `module` path; if they belong to the same org, they should be treated as `second-party`, not `local`):

```go
import (
    "github.com/mycorp/sdk/bar"      // second-party example
    "github.com/mycorp/myapp2/foo"   // second-party: same org, different module; not local
)
```

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
