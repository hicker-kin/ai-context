---
description: Go code style summary (see full rules)
paths:
  - "**/*.go"
---

# Go Code Style (Summary)

Follow the full rules in:

- `@ai_go/v1/rules/code_style.md`

When writing or generating Go code, **MUST** follow the **Formatting** and **Naming** sections in code_style.md (gofmt/goimports, import grouping, package/file/identifier naming, abbreviations, receiver names). These are mandatory.

## Key MUSTs

- Run `gofmt -s` (and prefer `goimports`).
- Avoid repeating receiver or package names in functions.
- Return `error` last; wrap with `fmt.Errorf("...: %w", err)`.
- Prefer guard clauses and small, focused functions.
- Exported identifiers need proper godoc comments.
- `context.Context` is the first param; do not store it in structs.
- Prevent goroutine leaks; do not copy `sync.Mutex`/`sync.WaitGroup`.
- Request DTOs: explicit `json` tags; with Gin use `binding`; with other frameworks use their validation.
