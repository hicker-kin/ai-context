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
- MUST keep each physical line containing Go code tokens at most **120 bytes**
  (UTF-8 byte length, not rune/character count). Pure comment-only lines are
  exempt. A line containing code plus a trailing comment is measured as one
  complete physical line. Break long statements across lines rather than
  exceeding the limit.
- Example:

```go
// BAD — line exceeds 120 bytes
err := fmt.Errorf("failed to load user profile for id=%s from remote store after retries: %w", userID, err)

// GOOD — pure comment lines are not subject to the code-line byte limit
// This comment may contain longer design context because it contains no Go code token.

// GOOD — wrap within 120 bytes
err := fmt.Errorf(
    "failed to load user profile for id=%s from remote store after retries: %w",
    userID,
    err,
)
```

- MUST group imports as: standard library, third-party, local. Use blank lines
between groups. Example:

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

    "mycorp/app/internal/bar" // local package(go.mod 的 module)
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

- Do not repeat the package name in any identifier (types, structs, variables,
functions, methods). The prefix of an identifier must not match the package name,
regardless of case (e.g. `federation`, `Federation`, `FEDERATION`).
- Example:

```go
// BAD
package federation

type FederationService struct {
    connectorRepo IdPConnectorRepository
    oidcExchange  OIDCExchange
    userRepo      user.UserRepository
    authSvc       *auth.AuthService
}

var federationConfigDefault = Config{}

func ParseFederationConfig(input string) (*Config, error) { return nil, nil }

// GOOD
package federation

type Service struct {
    connectorRepo IdPConnectorRepository
    oidcExchange  OIDCExchange
    userRepo      user.UserRepository
    authSvc       *auth.AuthService
}

var defaultConfig = Config{}

func Parse(input string) (*Config, error) { return nil, nil }
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

- Do not repeat the package name in function names (see Naming above).
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

### Size, structure, and reuse

- MUST keep a single function or method within **150 lines** (all lines from the
  signature through the closing `}`).
- MUST comment every **important node**: non-obvious control branches, error-handling
  trade-offs, state transitions, external I/O boundaries, and invariant/guard checks.
  Do **not** pile `what` comments on self-explanatory statements.
- When a function or method has **more than 3 distinct responsibilities or phases**
  (e.g. validate → load → transform → persist → notify counts as 5), MUST mark each
  phase with `// step1: ...` through `// stepN: ...` (English) at the start of that
  phase. See Comments for how this interacts with "why, not what".
- MUST prefer extracting reusable helpers (package-private or shared) over long
  procedural "wall of code". If a function would exceed 150 lines or accumulate too
  many responsibilities, MUST split it rather than stretch a script-style body.
- Code line length MUST follow Formatting (≤ 120 bytes; pure comment-only
  lines are exempt).
- Example (multi-phase with steps + helpers):

```go
// BAD — script-style wall of code, no step markers, mixed responsibilities inline
func (s *Service) CreateOrder(ctx context.Context, req CreateOrderReq) error {
    if req.UserID == "" {
        return ErrInvalid
    }
    u, err := s.users.Get(ctx, req.UserID)
    // ... dozens of inline lines for pricing, inventory, persist, notify ...
    return err
}

// GOOD — steps for >3 phases; extract reusable helpers
func (s *Service) CreateOrder(ctx context.Context, req CreateOrderReq) error {
    // step1: validate input
    if err := validateCreateOrder(req); err != nil {
        return err
    }
    // step2: load dependencies
    u, err := s.users.Get(ctx, req.UserID)
    if err != nil {
        return fmt.Errorf("load user: %w", err)
    }
    // step3: compute order
    order, err := buildOrder(u, req)
    if err != nil {
        return fmt.Errorf("build order: %w", err)
    }
    // step4: persist
    if err := s.orders.Save(ctx, order); err != nil {
        return fmt.Errorf("save order: %w", err)
    }
    // step5: notify
    return s.notify.OrderCreated(ctx, order.ID)
}
```

## Interfaces

- Name interfaces by behavior (e.g. `Reader`, `Repository`), not by implementation
(e.g. avoid `ReaderInterface`). Prefer one or a few methods per interface when
possible.
- Define interfaces in the **consuming** layer (e.g. in `service` that uses a repo),
not next to the implementation; see `project_architecture.md`.

## Slices and nil

- A nil slice is a valid "no elements" value. The standard `encoding/json`
  package encodes a nil slice as `null` and a non-nil empty slice such as
  `[]T{}` as `[]`. Keep package and API contracts consistent: return a non-nil
  empty slice when the response requires a JSON array; otherwise a nil slice is
  acceptable.
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

- Exception: `// step1: ...` through `// stepN: ...` structural markers are
  **required** for functions with more than 3 responsibilities (see Functions and
  Methods). The text after the colon MUST still be meaningful English (phase intent),
  not a restatement of the next line of code.
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

- When writing a method or function, **MUST** consider whether the work has a
  lifecycle (cancelable I/O, long-running loops, background goroutines, or work
  that must stop on process/request shutdown). Pure sync helpers with no
  cancelable work do not need a context.
- If lifecycle may be involved, **MUST** take `ctx context.Context` as the
  **first** parameter (after the receiver).
- Example:

```go
// BAD
func (s *Service) Do(userID string, ctx context.Context) error { return nil }

// GOOD
func (s *Service) Do(ctx context.Context, userID string) error { return nil }
```

- If the task **MUST** end when the owning process or request exits, **MUST**
  pass a context whose cancel is tied to that owner (request ctx,
  signal-derived root, or `WithCancel`/`WithTimeout` derived from that parent).
  **MUST NOT** start such work with a fresh `context.Background()` /
  `context.TODO()` — that can leave goroutines uncancellable (“zombie”) and
  block clean shutdown.
- Example:

```go
// BAD — Background cannot be cancelled on process shutdown; goroutine may become zombie
go worker.Run(context.Background())

// GOOD — pass parent ctx that main/signal/request can cancel
go worker.Run(ctx) // ctx from main WithCancel / signal.NotifyContext / request
```

- `context.Background()` / `context.TODO()` **MAY** only appear at intentional
  lifetime roots (e.g. `main` bootstrap, tests, or an explicitly independent
  background job with its own cancel/shutdown hook). Child work **MUST** still
  receive a derived, cancellable child of that root—not a new Background.
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

- Effective Go: [https://go.dev/doc/effective_go](https://go.dev/doc/effective_go)
- Go Code Review Comments: [https://go.dev/wiki/CodeReviewComments](https://go.dev/wiki/CodeReviewComments)
- Google Go Style Guide: [https://google.github.io/styleguide/go/](https://google.github.io/styleguide/go/)
- Google Go Style Best Practices: [https://google.github.io/styleguide/go/best-practices](https://google.github.io/styleguide/go/best-practices)
