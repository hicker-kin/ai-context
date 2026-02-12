# Go Performance & Optimization Rules

## Scope

Guidelines for efficient Go services. Profile first; optimize with evidence.

## Core MUSTs

- Profile before optimizing (`pprof`, tracing); avoid speculative micro-optimizations.
- Always bound concurrency and operations with timeouts (`context`); no unbounded goroutines/channels.
- Avoid hot-loop DB/HTTP calls; batch or cache when possible.
- Use buffered I/O; prefer bulk reads/writes for throughput.
- Pre-size slices when length is known or bounded; avoid loop-time allocations.
- Avoid heavy allocations in hot paths; reuse buffers or `sync.Pool` only where profiling shows benefit.
- Prefer simple, predictable code over cleverness; measure after changes.
- Configure connection pools (DB/HTTP) with sane limits (e.g., max open/idle, lifetime).
- Avoid N+1 queries; prefer batch/JOIN; use prepared statements for hot paths.
- Keep goroutine counts controlled (worker pool/errgroup) and locks granular to reduce contention.

## Good / Bad Examples

### Bounded concurrency with timeout (GOOD)

```go
sem := make(chan struct{}, 8) // bounded
for _, task := range tasks {
    sem <- struct{}{}
    go func(task Task) {
        defer func() { <-sem }()
        ctx, cancel := context.WithTimeout(parent, 500*time.Millisecond)
        defer cancel()

        _ = worker.Do(ctx, task)
    }(task)
}
```

### Unbounded goroutines and no timeout (BAD)

```go
for _, task := range tasks {
    go worker.Do(context.Background(), task) // unbounded, no timeout ❌
}
```

### Hot-path allocation avoidance (GOOD)

```go
buf := bytes.NewBuffer(make([]byte, 0, 1024)) // preallocated
for _, rec := range records {
    buf.Reset()
    encode(rec, buf) // reuses backing array ✅
}
```

### Repeated formatting in hot loop (BAD)

```go
for _, rec := range records {
    line := fmt.Sprintf("%v", rec) // alloc every iteration ❌
    sink(line)
}
```

### sync.Pool for hot, short-lived buffers (GOOD)

```go
var bufferPool = sync.Pool{New: func() any { return new(bytes.Buffer) }}

func ProcessData(data []byte) string {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer func() {
        buf.Reset()
        bufferPool.Put(buf)
    }()
    buf.Write(data)
    return buf.String()
}
```

### Unnecessary string/[]byte conversions (BAD/GOOD)

```go
// BAD: allocates twice
func process(s string) {
    b := []byte(s)      // alloc
    result := string(b) // alloc
    _ = result
}

// GOOD: strings.Builder with pre-grow
func build(parts []string) string {
    var b strings.Builder
    b.Grow(estimate(parts))
    for _, p := range parts {
        b.WriteString(p)
    }
    return b.String()
}
```

### N+1 queries vs batch/JOIN (BAD/GOOD)

```go
// BAD: N+1 in loop
for _, id := range orderIDs {
    order := getOrder(ctx, id)
    order.Items = getOrderItems(ctx, id) // repeated queries ❌
    orders = append(orders, order)
}

// GOOD: single batch/JOIN
const q = `
SELECT o.id, o.user_id, i.id, i.order_id, i.sku
FROM orders o
LEFT JOIN order_items i ON o.id = i.order_id
WHERE o.id = ANY($1)
`
rows, err := db.QueryContext(ctx, q, pq.Array(orderIDs))
```

### Connection pool configuration (GOOD)

```go
db, _ := sql.Open("postgres", dsn)
db.SetMaxOpenConns(50)
db.SetMaxIdleConns(10)
db.SetConnMaxLifetime(30 * time.Minute)
db.SetConnMaxIdleTime(5 * time.Minute)
```

### Cache hit-path vs miss-path (GOOD/BAD)

```go
// GOOD: cache first, TTL, safe async write
if v, err := cache.Get(key); err == nil {
    return v, nil
}
val, err := repo.Get(ctx, key)
if err != nil {
    return nil, err
}
go func(v any) {
    ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    defer cancel()
    _ = cache.Set(ctx, key, v, time.Hour)
}(val)

// BAD: no TTL, no error handling, potential stale data
cache.Set(context.Background(), key, val, 0) // immortal ❌
```

### JSON streaming vs loading all (BAD/GOOD)

```go
// BAD: load entire large JSON into memory
data, _ := io.ReadAll(r)
var items []Item
_ = json.Unmarshal(data, &items) // huge alloc ❌

// GOOD: streaming decode
dec := json.NewDecoder(r)
for dec.More() {
    var it Item
    if err := dec.Decode(&it); err != nil {
        return err
    }
    handle(it)
}
```

## Data Access Patterns

- Prefer prepared/parameterized statements reused across calls; avoid string-concatenated SQL.
- Batch queries/commands when supported; avoid N+1 (use JOIN/bulk fetch).
- Cache read-heavy data (local/Redis); define TTL and invalidation rules; protect against cache penetration.
- Configure connection pools: max open/idle, lifetime, idle timeout sized to workload.

## Memory and CPU

- Choose appropriate structures (e.g., `map[string]T` vs slice scan).
- Avoid copying large structs; pass pointers intentionally.
- Use `sync.Pool` only for high-frequency, short-lived objects and only after profiling.
- Favor zero-allocation logging/serialization on hot paths when warranted by measurements.
- Small structs (<~64B) can be passed by value to avoid heap allocs; large structs by pointer.
- Pre-size slices (`make(T, 0, n)`) when `n` known/bounded; avoid append in tight loops without capacity.

## I/O

- Use buffered readers/writers for files/network (`bufio`).
- Use connection pooling (DB/HTTP) and keep-alive; avoid opening per-request connections.
- Set deadlines on net connections (`SetDeadline`/`SetReadDeadline`/`SetWriteDeadline`).

## Observability for Performance

- Expose latency, error rate, QPS, and resource usage metrics per endpoint/operation.
- Capture traces around hot paths; verify spans show bounded fan-out and timing.

## Concurrency Patterns

- Use worker pools for bulk tasks; bound queue sizes.
- Use `errgroup.WithContext` for fan-out with cancellation.
- Reduce lock contention with sharded locks where needed; prefer fine-grained over coarse.

## Caching Patterns

- Local cache for hot, small datasets; Redis/remote cache for cross-instance sharing.
- Set TTL and invalidation; avoid stale data risks.
- Populate cache asynchronously only when safe; ensure context/timeout on cache I/O.

## JSON Handling

- For large JSON, prefer streaming decode (`json.Decoder`) to avoid loading all into memory.
- Consider faster encoders (e.g., json-iterator) only when profiling shows benefit; keep compatibility in mind.

## Benchmarks and Memory Checks

- Use `b.ReportAllocs()`; keep setup outside the timed loop or use `b.ResetTimer()`.
- Add parallel benchmarks with `b.RunParallel` when relevant.
- Use heap/alloc profiles to verify optimizations; compare before/after.

## Performance Review Checklist

- [ ] Pre-size slices; avoid loop allocations
- [ ] Goroutine count bounded; contexts carry deadlines
- [ ] Locks scoped/granular; no obvious contention hot spots
- [ ] N+1 avoided; queries indexed; pool configured
- [ ] Hot data cached; cache invalidation/TTL defined
- [ ] Benchmarks/pprof collected; changes measured
