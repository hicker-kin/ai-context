# Go Code Style

## Scope

This document defines base Go syntax, naming, and style rules. Architecture and
project structure are defined in `project_architecture.md`.

## Rule Levels

- MUST: mandatory
- SHOULD: recommended
- MAY: optional

## Formatting

- MUST run `gofmt -s` on all Go files.
- SHOULD use `goimports` to manage imports.
- SHOULD keep lines reasonably short (<= 120) unless it harms readability.
- SHOULD group imports as: standard library, third-party, local. Use blank lines
  between groups.
- Example:

```go
// BAD
import (
    "github.com/acme/foo"
    "fmt"
    "mycorp/app/internal/bar"
)

// GOOD
import (
    "error"
    "fmt"

    "github.com/acme/foo" // third-party

    "mycorp/sdk/foo"  // second-party

    "mycorp/app/internal/bar" // local
)
```

## File Layout Order

- `package`, `import`, `const`, `var`, `type`, `func`
- Place methods near their receiver type.
- Example:

```go
// BAD
package user

func (u *User) Name() string { return "" }

type User struct{}

const defaultTimeout = 3 * time.Second

// GOOD
package user

const defaultTimeout = 3 * time.Second

type User struct{}

func (u *User) Name() string { return "" }
```

## Naming

- Package names: lower-case, short, singular, no underscores.
- Example:

```go
// BAD
package user_profiles

// GOOD
package user
```

- File names: lower-case; use underscores only when needed for readability.
- Example:

```go
// BAD
// UserProfile.go
// GOOD
// user_profile.go
```

- Exported identifiers: CamelCase; unexported identifiers: lower camel.
- Example:

```go
// BAD
type userService struct{}

// GOOD
type UserService struct{}
```

- Abbreviations: use consistent forms (ID, URL, HTTP, JSON, DB).
- Example:

```go
// BAD
userId := "123"

// GOOD
userID := "123"
```

- Receiver names: 1-2 letters, consistent per type.
- Example:

```go
// BAD
func (service *UserService) Create(ctx context.Context) error {
    return nil
}

// GOOD
func (s *UserService) Create(ctx context.Context) error {
    return nil
}
```

- Avoid repeating the package name in type names.
- Example:

```go
// BAD
package yamlconfig

type YAMLConfig struct{}

// GOOD
package yamlconfig

type Config struct{}
```

- Avoid repeating the package name in variable names.
- Example:

```go
// BAD
package yamlconfig

var yamlConfigDefault = Config{}

// GOOD
package yamlconfig

var defaultConfig = Config{}
```

- In a function, do not reuse variable names for different meanings.
- Example:

```go
// BAD
func BuildUser(ctx context.Context, cfg *Config) (*User, error) {
    if cfg == nil {
        cfg := DefaultConfig() // shadowed name, different meaning
        _ = cfg
    }
    return nil, nil
}

// GOOD
func BuildUser(ctx context.Context, cfg *Config) (*User, error) {
    if cfg == nil {
        defaultCfg := DefaultConfig()
        _ = defaultCfg
    }
    return nil, nil
}
```

- Within the same package, avoid reusing the same identifier for different
  meanings across files.
- Example:

```go
// BAD (file a)
var cfg = LoadDBConfig()

// BAD (file b)
var cfg = LoadCacheConfig()

// GOOD
var dbCfg = LoadDBConfig()
var cacheCfg = LoadCacheConfig()
```

- Use `const` for invariants; use `iota` for enumerated constants.
- Example:

```go
// GOOD
const defaultTimeout = 10 * time.Second

type Status int
const (
    StatusUnknown Status = iota
    StatusActive
    StatusDone
)
```

## Request DTO Tags

- When using **Gin**, use the `binding` tag for request-body validation; when using
  other frameworks (e.g. Echo, Fiber), follow that framework's validation mechanism
  and tag/option conventions.
- Request structs MUST specify explicit `json` tags.
- Required fields MUST include `binding:"required"` if required (Gin), or the
  equivalent for your framework.
- If a field has constraints, include thresholds in `binding` (e.g. `min=3,max=64`)
  for Gin, or the equivalent for your framework.
- Optional fields SHOULD use `omitempty` in `json` tags.
- Example:

```go
// BAD
type CreateCategoryReq struct {
    Username    string
    Name        string
    Code        string
    Description string
}

// GOOD
type CreateCategoryReq struct {
    Username    string `json:"username" binding:"required,min=3,max=64"`
    Name        string `json:"name" binding:"required"`
    Code        string `json:"code" binding:"required"`
    Description string `json:"description,omitempty"`
}
```

## Response DTO Tags

- Response structs MUST specify explicit `json` tags for API output.
- Optional or zero-value fields SHOULD use `omitempty` so absent values are omitted
  from JSON when appropriate.
- Prefer consistent field naming (e.g. snake_case in JSON if that is your API
  convention) and document the response shape (e.g. in OpenAPI).

## Functions and Methods

- Use verbs for actions (CreateUser, ValidateEmail).
- Example:

```go
// BAD
func UserCreation(u User) error { return nil }

// GOOD
func CreateUser(u User) error { return nil }
```

- Avoid repeating the receiver type in method names.
- Example:

```go
// BAD
func (u *User) UserValidateEmail() error { return nil }

// GOOD
func (u *User) ValidateEmail() error { return nil }
```

- Avoid repeating the package name in function names.
- Example:

```go
// BAD
package yamlconfig

func ParseYAMLConfig(input string) (*Config, error) { return nil, nil }

// GOOD
package yamlconfig

func Parse(input string) (*Config, error) { return nil, nil }
```

- Avoid "Get" prefix for simple accessors; use noun-like names.
- Example:

```go
// BAD
func (c *Config) GetJobName(key string) (string, bool) { return "", false }

// GOOD
func (c *Config) JobName(key string) (string, bool) { return "", false }
```

- Return `error` as the last result.
- Example:

```go
// BAD
func Load() (error, *Config) { return nil, nil }

// GOOD
func Load() (*Config, error) { return nil, nil }
```

- Use a **pointer receiver** when the method mutates the receiver, when the type is
  large, or for consistency if any method needs a pointer; use a **value receiver**
  for small, immutable types.
- Prefer passing **pointers** for large structs or when the callee may need to modify;
  pass by value for small types and to avoid accidental mutation.

## Interfaces

- Name interfaces by behavior (e.g. `Reader`, `Repository`), not by implementation
  (e.g. avoid `ReaderInterface`). Prefer one or a few methods per interface when
  possible.
- Define interfaces in the **consuming** layer (e.g. in `service` that uses a repo),
  not next to the implementation; see `project_architecture.md`.

## Slices and nil

- A nil slice is a valid "no elements" value; JSON encoding typically produces `[]`.
  Be consistent within a package: either return `nil` or `[]T{}` for "no results",
  and prefer `nil` unless the caller needs a non-nil empty slice for a specific reason.
- Example:

```go
// Both are valid; pick one convention per package.
func FindAll() []Item { return nil }
func FindAll() []Item { return []Item{} }
```

## Errors

- Wrap errors with context using `fmt.Errorf("context: %w", err)`.
- Example:

```go
// BAD
if err != nil {
    return fmt.Errorf("read config: %v", err)
}
// service error cannot panic
if err != nil {
  panic(err)
}


// GOOD
if err != nil {
    return fmt.Errorf("read config: %w", err)
}

func (l *Logic) Operation() error {
    user, err := l.svcCtx.UserModel.FindOne(l.ctx, id)
    if err != nil {
        // Wrap errors with context
        return fmt.Errorf("failed to find user %d: %w", id, err)
    }
    return nil
}
```

- Define sentinel errors as `var ErrNotFound = errors.New("not found")`.
- Example:

```go
// BAD
func Find(id string) error {
    return errors.New("not found")
}

// GOOD
var ErrNotFound = errors.New("not found")

func Find(id string) error {
    return ErrNotFound
}
```

- Use `errors.Is`/`errors.As`; avoid string comparisons.
- Example:

```go
// BAD
if err != nil && err.Error() == "not found" {
    return ErrNotFound
}

// GOOD
if errors.Is(err, ErrNotFound) {
    return ErrNotFound
}
```

- Error strings are lower-case with no trailing punctuation.
- Example:

```go
// BAD
var ErrNotFound = errors.New("Not Found.")

// GOOD
var ErrNotFound = errors.New("not found")
```

- Do not panic in service or handler code; return errors. Panic is only acceptable
  in package `main`/init or when a programming bug is unrecoverable.
- Example:

```go
// BAD (in service/handler)
if err != nil {
    panic(err)
}

// GOOD
if err != nil {
    return fmt.Errorf("operation: %w", err)
}
```

## Control Flow and Style

- Prefer guard clauses; avoid `else` after `return`.
- Example:

```go
// BAD
if err != nil {
    return err
} else {
    return nil
}

// GOOD
if err != nil {
    return err
}
return nil
```

- Avoid deep nesting; keep functions focused and small.
- Example:

```go
// BAD
if ok {
    if err == nil {
        if ready {
            doWork()
        }
    }
}

// GOOD
if !ok {
    return
}
if err != nil {
    return
}
if !ready {
    return
}
doWork()
```

- Prefer `switch` for multi-branch logic.
- Example:

```go
// BAD
if status == "new" {
    handleNew()
} else if status == "done" {
    handleDone()
} else {
    handleOther()
}

// GOOD
switch status {
case "new":
    handleNew()
case "done":
    handleDone()
default:
    handleOther()
}
```

- Avoid naked returns except in very short functions.
- Example:

```go
// BAD
func (s *Store) Find(id string) (u User, err error) {
    u, err = s.db.Get(id)
    if err != nil {
        return
    }
    return
}

// GOOD
func (s *Store) Find(id string) (User, error) {
    u, err := s.db.Get(id)
    if err != nil {
        return User{}, err
    }
    return u, nil
}
```

## Comments

- Exported identifiers MUST have godoc comments starting with the name.
- Example:

```go
// BAD
// handles user storage
type UserStore struct{}

// GOOD
// UserStore handles user storage.
type UserStore struct{}
```

- Comments explain "why", not "what".
- Example:

```go
// BAD
i++ // increment i

// GOOD
i++ // skip sentinel value 0
```

- Remove stale comments; avoid commented-out code.
- Example:

```go
// BAD
// old behavior kept for reference
// doThingOld()

// GOOD
// Use version control history instead of commented-out code.
```

## Context and Concurrency

- Pass `context.Context` as the first parameter for request-scoped APIs.
- Example:

```go
// BAD
func (s *Service) Do(userID string, ctx context.Context) error { return nil }

// GOOD
func (s *Service) Do(ctx context.Context, userID string) error { return nil }
```

- Do not store `context.Context` in structs.
- Example:

```go
// BAD
type Service struct {
    ctx context.Context
}

// GOOD
type Service struct{}

func (s *Service) Do(ctx context.Context) error { return nil }
```

- Goroutines MUST have a clear cancel/exit path to avoid leaks.
- Example:

```go
// BAD
go func() {
    for {
        work()
    }
}()

// GOOD
go func(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        default:
            work()
        }
    }
}(ctx)
```

- Do not copy values containing `sync.Mutex`/`sync.WaitGroup`.
- Example:

```go
// BAD
type Counter struct {
    mu sync.Mutex
    n  int
}

func Copy(c Counter) Counter { // copies mutex
    return c
}

// GOOD
func Copy(c *Counter) *Counter { // avoid copying mutex
    return c
}
```

- Use `defer` for cleanup (e.g. `defer f.Close()`, `defer mu.Unlock()`), so it runs
  on all return paths and keeps code next to the acquire.

## Logging (Style Only)

- Log errors at boundaries; avoid logging the same error at multiple layers.
- Prefer structured logging with key-value fields when available.

## Summary

### Always Do

1. Keep handlers thin, logic thick
2. Use structured logging with context
3. Handle all errors explicitly
4. Validate input thoroughly
5. Use connection pooling
6. Enable caching for read-heavy data
7. Write unit tests
8. Use transactions for atomic operations
9. Monitor production metrics
10. If unsure about a best practice or implementation detail, say so instead of guessing
11. Follow RESTful API design principles and best practices

### Never Do

1. Put business logic in handlers
2. Ignore errors
3. Create connections in handlers
4. Query in loops
5. Disable resilience features in production
6. Use global variables
7. Block without timeouts
8. Create unbounded goroutines

## References

- Effective Go: <https://go.dev/doc/effective_go>
- Go Code Review Comments: <https://go.dev/wiki/CodeReviewComments>
- Google Go Style Guide: <https://google.github.io/styleguide/go/>
- Google Go Style Best Practices: <https://google.github.io/styleguide/go/best-practices>
