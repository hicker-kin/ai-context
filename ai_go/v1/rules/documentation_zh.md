# Go 文档规则

## 适用范围

Go 代码与项目产物的文档约定。与架构和代码风格规则配套使用。

## 核心必须项（MUST）

- 所有导出标识符必须有以标识符名开头的 godoc 注释。
- 包级文档说明用途、边界及并发/副作用语义。
- 文档化错误语义及非显而易见的设计决策（说明“为什么”，而非“做什么”）。
- 文档与代码同步；业务/API 变更需更新 `docs/design` 和 `docs/changelog`。
- 对复杂 API 提供示例（`Example...` 函数）。

## 良好 / 不良示例

### 带并发说明的清晰 godoc（良好）

```go
// Cache 提供基于 TTL 的内存缓存。
// 并发安全。
type Cache struct { /* ... */ }
```

### 模糊或缺少文档（不良）

```go
// 做某事
type Cache struct{} // 用途不明确 ❌
```

### 示例函数（良好）

```go
func ExampleCache_Get() {
    c := NewCache(time.Minute)
    _ = c.Set("k", "v")
    v, _ := c.Get("k")
    fmt.Println(v)
    // Output: v
}
```

## 文档位置

- API / 设计变更 → `docs/design/`
- 变更日志 / SDD → `docs/changelog/`
- Swagger/OpenAPI → `docs/swagger/`
- 保持 README/使用示例与实际 flags/config 一致。

## 内容指南

- 优先简短、可执行的表述；避免重复代码。
- 说明不变量、前置条件及并发预期。
- 对非显而易见的性能特征加以说明（如“O(n) 扫描”、“每次调用分配”）。
- 移除过时注释；用版本控制替代被注释掉的代码。
