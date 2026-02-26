# Go 代码质量规则

## 适用范围

与 `code_style.md` 配套使用，聚焦更高层面的质量实践（部分源自 continue.dev 规则）。

## 核心必须项（MUST）

- 显式错误处理：`if err != nil { ... }`；用上下文包装（`%w`）。
- 优先组合而非继承；使用小而专注的接口。
- 包组织清晰；保持 handler 薄、service 厚。
- 用 `defer` 做资源清理（`Close`、`Unlock`）。
- 可读性优于过早优化；函数保持小而聚焦。
- 使用合适的并发原语；避免无生命周期控制的临时 goroutine。

## 良好 / 不良示例

### 显式错误处理 + defer 清理（良好）

```go
f, err := os.Open(path)
if err != nil {
    return fmt.Errorf("open %s: %w", path, err)
}
defer f.Close()
```

### 忽略错误且缺少清理（不良）

```go
f, _ := os.Open(path) // 忽略错误 ❌
data, _ := io.ReadAll(f)
_ = data // 泄漏：未关闭 ❌
```

### 组合优于继承（良好）

```go
type Storer interface {
    Save(ctx context.Context, in Item) error
}

type Service struct {
    store Storer
}
```

### Handler 泄露业务逻辑（不良）

```go
func Create(c *gin.Context) {
    // 在这里做校验、写 DB、构建领域对象 ❌
}
```

## 额外指南

- 保持 import 分组（标准库/第三方/本地）；运行 `gofmt -s`，优先 `goimports`。
- 避免全局可变状态；显式注入依赖。
- 命名清晰；标识符中不重复包名。
- 使用卫语句；避免深层嵌套。
- 不记录敏感数据；在边界附近只记录一次。
