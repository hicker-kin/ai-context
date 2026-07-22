---
description: Go code style summary (see full rules)
paths:
  - "**/*.go"
---

# Go Code Style (Summary)

Follow the full rules in:

- `@ai_go/v1/rules/code_style.md`
- `@.ai-context/rules/code_style.md`
- `@.ai-context/rules/code_style_zh.md` (中文版)
- `@ai_go/v1/rules/code_style_zh.md` (中文版)

When writing or generating Go code, **MUST** follow the **Formatting** and **Naming** sections in code_style.md (gofmt/goimports, import grouping, package/file/identifier naming, abbreviations, receiver names). These are mandatory.

## Key MUSTs

- Run `gofmt -s` (and prefer `goimports`).
- Each line MUST be ≤ 120 bytes (UTF-8); each function/method MUST be ≤ 150 lines.
- Comment every important node (non-obvious branches, error trade-offs, state transitions, I/O boundaries, guards).
- Functions with more than 3 responsibilities MUST use `// step1: ...` … `// stepN: ...` (English).
- Prefer extracting reusable helpers over script-style wall-of-code.
- Avoid repeating receiver or package names in functions.
- Return `error` last; wrap with `fmt.Errorf("...: %w", err)`.
- Prefer guard clauses and small, focused functions.
- Exported identifiers need proper godoc comments.
- Consider function lifecycle; if cancelable/background work may apply, first param MUST be `ctx context.Context`; do not store ctx in structs.
- Propagate a parent-controlled ctx for shutdown-bound tasks — do not use fresh `Background`/`TODO` (avoids zombie goroutines); do not copy `sync.Mutex`/`sync.WaitGroup`.
- Request DTOs: explicit `json` tags; with Gin use `binding`; with other frameworks use their validation.
