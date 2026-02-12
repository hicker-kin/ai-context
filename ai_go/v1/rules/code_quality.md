# Go Code Quality Rules

## Scope

Complements `code_style.md` with higher-level quality practices (many sourced from continue.dev rules).

## Core MUSTs

- Explicit error handling: `if err != nil { ... }`; wrap with context (`%w`).
- Prefer composition over inheritance; small, purpose-specific interfaces.
- Organize packages clearly; keep handlers thin, services thick.
- Clean up resources with `defer` (`Close`, `Unlock`).
- Favor readability over premature optimization; keep functions small and focused.
- Use appropriate concurrency primitives; avoid ad-hoc goroutines without lifecycle control.

## Good / Bad Examples

### Explicit error handling + defer cleanup (GOOD)

```go
f, err := os.Open(path)
if err != nil {
    return fmt.Errorf("open %s: %w", path, err)
}
defer f.Close()
```

### Ignored error and missing cleanup (BAD)

```go
f, _ := os.Open(path) // error ignored ❌
data, _ := io.ReadAll(f)
_ = data // leak: no close ❌
```

### Composition over inheritance (GOOD)

```go
type Storer interface {
    Save(ctx context.Context, in Item) error
}

type Service struct {
    store Storer
}
```

### Leaky handler with business logic (BAD)

```go
func Create(c *gin.Context) {
    // validates, writes DB, builds domain object here ❌
}
```

## Additional Guidelines

- Keep imports grouped (std/third-party/local); run `gofmt -s` and prefer `goimports`.
- Avoid global mutable state; inject dependencies explicitly.
- Prefer clear names; avoid repeating package names in identifiers.
- Use guard clauses; avoid deep nesting.
- Do not log sensitive data; log once near boundaries.
