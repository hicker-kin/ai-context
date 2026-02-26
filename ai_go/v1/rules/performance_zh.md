# Go 性能与优化规则

## 适用范围

Go 服务的高效开发指南。先做性能分析，再基于数据优化。

## 核心必须项（MUST）

- 先分析再优化（pprof、追踪）；避免无根据的微优化。
- 始终用超时（`context`）约束并发与操作；禁止无限 goroutine/channel。
- 避免热路径中的循环 DB/HTTP 调用；尽可能批量或缓存。
- 使用缓冲 I/O；优先大批量读写以提高吞吐。
- 长度已知或可预测时预分配 slice；避免循环内分配。
- 避免热路径上的大量分配；仅在分析证明有益时复用 buffer 或使用 `sync.Pool`。
- 优先选择简单、可预测的代码，而非技巧；变更后进行测量。
- 合理配置连接池（DB/HTTP）限制（如 max open/idle、生命周期等）。
- 避免 N+1 查询；优先批量/JOIN；热路径使用预编译语句。
- 控制 goroutine 数量（worker pool/errgroup），缩小锁粒度以降低争用。

## 良好 / 不良示例

### 有界并发 + 超时（良好）

```go
sem := make(chan struct{}, 8) // 有界
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

### 无限 goroutine 且无超时（不良）

```go
for _, task := range tasks {
    go worker.Do(context.Background(), task) // 无界、无超时 ❌
}
```

### 热路径避免分配（良好）

```go
buf := bytes.NewBuffer(make([]byte, 0, 1024)) // 预分配
for _, rec := range records {
    buf.Reset()
    encode(rec, buf) // 复用底层数组 ✅
}
```

### 热循环中重复格式化（不良）

```go
for _, rec := range records {
    line := fmt.Sprintf("%v", rec) // 每次迭代都分配 ❌
    sink(line)
}
```

### 热路径短生命周期 buffer 使用 sync.Pool（良好）

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

### 不必要的 string/[]byte 转换（不良/良好）

```go
// 不良：两次分配
func process(s string) {
    b := []byte(s)      // 分配
    result := string(b) // 分配
    _ = result
}

// 良好：strings.Builder 预增长
func build(parts []string) string {
    var b strings.Builder
    b.Grow(estimate(parts))
    for _, p := range parts {
        b.WriteString(p)
    }
    return b.String()
}
```

### N+1 查询 vs 批量/JOIN（不良/良好）

```go
// 不良：循环内 N+1
for _, id := range orderIDs {
    order := getOrder(ctx, id)
    order.Items = getOrderItems(ctx, id) // 重复查询 ❌
    orders = append(orders, order)
}

// 良好：单次批量/JOIN
const q = `
SELECT o.id, o.user_id, i.id, i.order_id, i.sku
FROM orders o
LEFT JOIN order_items i ON o.id = i.order_id
WHERE o.id = ANY($1)
`
rows, err := db.QueryContext(ctx, q, pq.Array(orderIDs))
```

### 连接池配置（良好）

```go
db, _ := sql.Open("postgres", dsn)
db.SetMaxOpenConns(50)
db.SetMaxIdleConns(10)
db.SetConnMaxLifetime(30 * time.Minute)
db.SetConnMaxIdleTime(5 * time.Minute)
```

### 缓存命中路径 vs 未命中路径（良好/不良）

```go
// 良好：先查缓存，TTL，安全异步写入
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

// 不良：无 TTL、无错误处理、可能产生脏数据
cache.Set(context.Background(), key, val, 0) // 永不过期 ❌
```

### JSON 流式 vs 全部加载（不良/良好）

```go
// 不良：整份大 JSON 载入内存
data, _ := io.ReadAll(r)
var items []Item
_ = json.Unmarshal(data, &items) // 大块分配 ❌

// 良好：流式解码
dec := json.NewDecoder(r)
for dec.More() {
    var it Item
    if err := dec.Decode(&it); err != nil {
        return err
    }
    handle(it)
}
```

## 数据访问模式

- 优先复用预编译/参数化语句；避免 SQL 字符串拼接。
- 在支持时批量查询/命令；避免 N+1（使用 JOIN/批量拉取）。
- 对读多数据使用缓存（本地/Redis）；定义 TTL 与失效策略；防止缓存穿透。
- 配置连接池：max open/idle、lifetime、idle timeout 按负载调整。

## 内存与 CPU

- 选择合适的结构（如 `map[string]T` 与 slice 扫描）。
- 避免复制大结构体；需要时显式传指针。
- 仅对高频率、短生命周期对象使用 `sync.Pool`，且需在分析后再用。
- 在测量证明必要时，热路径上优先零分配日志/序列化。
- 小结构体（约 <64B）可按值传递以减少堆分配；大结构体用指针。
- 长度 n 已知或可预估时预分配 slice（`make(T, 0, n)`）；避免在紧凑循环中无容量 append。

## I/O

- 对文件/网络使用缓冲读写器（`bufio`）。
- 使用连接池（DB/HTTP）与 keep-alive；避免每个请求新建连接。
- 为网络连接设置截止时间（`SetDeadline`/`SetReadDeadline`/`SetWriteDeadline`）。

## 性能可观测性

- 按端点/操作暴露延迟、错误率、QPS 及资源使用指标。
- 对热路径采集 trace；确认 span 显示有界扇出与耗时。

## 并发模式

- 批量任务使用 worker pool；限制队列大小。
- 带取消的扇出使用 `errgroup.WithContext`。
- 需要时用分片锁降低锁争用；优先细粒度锁。

## 缓存模式

- 热点小数据集用本地缓存；跨实例共享用 Redis/远程缓存。
- 设置 TTL 与失效；避免脏数据风险。
- 仅在安全时异步填充缓存；确保 cache I/O 带 context/timeout。

## JSON 处理

- 大 JSON 优先流式解码（`json.Decoder`），避免整份载入内存。
- 仅在分析证明有收益时考虑更快的编码器（如 json-iterator）；注意兼容性。

## 基准与内存检查

- 使用 `b.ReportAllocs()`；setup 放在计时循环外或使用 `b.ResetTimer()`。
- 适用时使用 `b.RunParallel` 做并行基准。
- 用 heap/alloc profile 验证优化；做前后对比。

## 性能评审清单

- [ ] 预分配 slice；避免循环分配
- [ ] Goroutine 数量有界；context 携带截止时间
- [ ] 锁作用域清晰/粒度合适；无明显争用热点
- [ ] 避免 N+1；查询有索引；连接池已配置
- [ ] 热点数据有缓存；缓存失效/TTL 已定义
- [ ] 已收集基准/pprof；变更已测量
