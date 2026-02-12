# Go Testing Rules

## Scope

Practical testing conventions for Go services. Complements `project_architecture.md` (layering) and `code_style.md` (formatting/naming).

## Core MUSTs

- Use table-driven tests with subtests named by scenario (`missing_email`, `not_found`).
- Helpers call `t.Helper()`.
- Tests are deterministic: fixed seeds, no wall-clock dependence.
- Cover error and edge cases; validate behavior and returned errors.
- Bound resources: `context.WithTimeout`, `t.Cleanup` for teardown.
- Keep logging at boundaries only; prefer assertions over prints.
- For integration/contract tests on infra, ensure isolated data and cleanup.

## Good / Bad Examples

### Table-driven + gomock + timeout (GOOD)

```go
func mustOpen(t *testing.T, path string) *os.File {
    t.Helper()
    f, err := os.Open(path)
    if err != nil {
        t.Fatalf("open %s: %v", path, err)
    }
    return f
}

func TestGetUser(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    repo := mock.NewMockUserRepo(ctrl)
    repo.EXPECT().
        FindByID(gomock.Any(), int64(1)).
        Return(&User{ID: 1, Name: "john"}, nil)

    tests := []struct {
        name string
        id   int64
        want string
        err  bool
    }{
        {"ok", 1, "john", false},
        {"not_found", 2, "", true},
    }

    for _, tc := range tests {
        tc := tc
        t.Run(tc.name, func(t *testing.T) {
            t.Parallel()
            ctx, cancel := context.WithTimeout(context.Background(), time.Second)
            defer cancel()

            svc := NewService(repo)
            u, err := svc.GetUser(ctx, tc.id)
            if tc.err {
                require.Error(t, err)
                return
            }
            require.NoError(t, err)
            require.Equal(t, tc.want, u.Name)
        })
    }
}
```

### Non-deterministic and unstructured (BAD)

```go
func TestRand(t *testing.T) {
    r := rand.New(rand.NewSource(time.Now().UnixNano())) // nondeterministic ❌
    if r.Intn(2) == 0 {
        t.Fatal("flaky") // no scenario name, no structure ❌
    }
}
```

### Missing cleanup and no edge coverage (BAD)

```go
func TestRepo(t *testing.T) {
    repo := newRepo() // no cleanup ❌
    _ = repo.Save(context.Background(), "id", "value") // no error check ❌
}
```

## Integration / Contract Tests

- Isolate data (unique DB/schema or test tenant).
- Use factories/fixtures that clean up; prefer `t.Cleanup`.
- Avoid shared global state; inject dependencies.
- Assert external shapes for public APIs (status, body shape, error codes).

## Benchmarks

- Use `b.ReportAllocs()`, run with stable inputs, avoid allocations in setup inside loop.
- Guard parallel benchmarks with proper synchronization; avoid measuring unrelated work.
