# Go Documentation Rules

## Scope

Doc conventions for Go code and project artifacts. Complements architecture and code style rules.

## Core MUSTs

- Every exported identifier has a godoc comment starting with the identifier name.
- Package docs explain purpose, boundaries, and concurrency/side-effect semantics.
- Document error semantics and non-obvious design choices (“why”, not “what”).
- Keep docs in sync with code; update `docs/design` and `docs/changelog` for business/API changes.
- Provide examples (`Example...` functions) for complex APIs.

## Good / Bad Examples

### Clear godoc with concurrency note (GOOD)

```go
// Cache provides TTL-based in-memory caching.
// Safe for concurrent use.
type Cache struct { /* ... */ }
```

### Vague or missing doc (BAD)

```go
// does something
type Cache struct{} // unclear purpose ❌
```

### Example function (GOOD)

```go
func ExampleCache_Get() {
    c := NewCache(time.Minute)
    _ = c.Set("k", "v")
    v, _ := c.Get("k")
    fmt.Println(v)
    // Output: v
}
```

## Placement

- API / design changes → `docs/design/`
- Changelog / SDD → `docs/changelog/`
- Swagger/OpenAPI → `docs/swagger/`
- Keep README/usage snippets aligned with actual flags/config.

## Content Guidelines

- Prefer short, actionable statements; avoid duplicating code.
- State invariants, preconditions, and concurrency expectations.
- Note performance characteristics if non-obvious (e.g., “O(n) scan”, “allocates per call”).
- Remove stale comments; rely on VCS for history instead of commented-out code.
