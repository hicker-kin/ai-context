# Go 代码风格

## 适用范围

本文档定义 Go 的基础语法、命名及风格规则。架构与项目结构见 `project_architecture.md`。

## 规则级别

- MUST：必须
- SHOULD：建议
- MAY：可选

## 格式

- 对所有 Go 文件运行 `gofmt -s`。
- 建议使用 `goimports` 管理 import。
- 建议保持行长度适中（<= 120 字符），除非影响可读性。
- import 分组建议为：标准库、第三方、本地。组之间空行分隔。
- 示例：

```go
// 不良
import (
    "github.com/acme/foo"
    "fmt"
    "mycorp/app/internal/bar"
)

// 良好
import (
    "errors"
    "fmt"

    "github.com/acme/foo" // 第三方

    "mycorp/sdk/foo"  // 同集团（公司）其他项目调用

    "mycorp/app/internal/bar" // 本项目
)
```

## 文件布局顺序

- `package`、`import`、`const`、`var`、`type`、`func`
- 方法紧邻其接收者类型。
- 示例：

```go
// 不良
package user

func (u *User) Name() string { return "" }

type User struct{}

const defaultTimeout = 3 * time.Second

// 良好
package user

const defaultTimeout = 3 * time.Second

type User struct{}

func (u *User) Name() string { return "" }
```

## 命名

- 包名：小写、简短、单数、无下划线。
- 示例：

```go
// 不良
package user_profiles

// 良好
package user
```

- 文件名：小写；仅在有助于可读性时使用下划线。
- 示例：

```go
// 不良
// UserProfile.go
// 良好
// user_profile.go
```

- 导出标识符：CamelCase；未导出标识符：小驼峰。
- 示例：

```go
// 不良
type userService struct{}

// 良好
type UserService struct{}
```

- 缩写：统一形式（ID、URL、HTTP、JSON、DB）。
- 示例：

```go
// 不良
userId := "123"

// 良好
userID := "123"
```

- 接收者名：1–2 个字母，同类型保持一致。
- 示例：

```go
// 不良
func (service *UserService) Create(ctx context.Context) error {
    return nil
}

// 良好
func (s *UserService) Create(ctx context.Context) error {
    return nil
}
```

- 标识符中不得重复包名（类型、结构体、变量、函数、方法）。标识符前缀不得与包名相同（含大小写，如 `federation`、`Federation`、`FEDERATION`）。
- 示例：

```go
// 不良
package federation

type FederationService struct {
    connectorRepo IdPConnectorRepository
    oidcExchange  OIDCExchange
    userRepo      user.UserRepository
    authSvc       *auth.AuthService
}

var federationConfigDefault = Config{}

func ParseFederationConfig(input string) (*Config, error) { return nil, nil }

// 良好
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

- 函数内不同语义的变量不得复用同一变量名。
- 示例：

```go
// 不良
func BuildUser(ctx context.Context, cfg *Config) (*User, error) {
    if cfg == nil {
        cfg := DefaultConfig() // 变量遮蔽，语义不同
        _ = cfg
    }
    return nil, nil
}

// 良好
func BuildUser(ctx context.Context, cfg *Config) (*User, error) {
    if cfg == nil {
        defaultCfg := DefaultConfig()
        _ = defaultCfg
    }
    return nil, nil
}
```

- 同包内不同文件中，避免用同一标识符表示不同含义。
- 示例：

```go
// 不良（文件 a）
var cfg = LoadDBConfig()

// 不良（文件 b）
var cfg = LoadCacheConfig()

// 良好
var dbCfg = LoadDBConfig()
var cacheCfg = LoadCacheConfig()
```

- 不变量用 `const`；枚举常量用 `iota`。
- 示例：

```go
// 良好
const defaultTimeout = 10 * time.Second

type Status int
const (
    StatusUnknown Status = iota
    StatusActive
    StatusDone
)
```

## 请求 DTO 标签

- 使用 **Gin** 时，用 `binding` 标签做请求体验证；使用其它框架（如 Echo、Fiber）时，遵循该框架的校验机制与 tag/option 约定。
- 请求结构体必须显式指定 `json` 标签。
- 必填字段在 Gin 中需包含 `binding:"required"`，或使用对应框架等价写法。
- 若有约束，在 Gin 的 `binding` 中给出阈值（如 `min=3,max=64`），或使用框架等价写法。
- 可选字段建议在 `json` 标签中使用 `omitempty`。
- 示例：

```go
// 不良
type CreateCategoryReq struct {
    Username    string
    Name        string
    Code        string
    Description string
}

// 良好
type CreateCategoryReq struct {
    Username    string `json:"username" binding:"required,min=3,max=64"`
    Name        string `json:"name" binding:"required"`
    Code        string `json:"code" binding:"required"`
    Description string `json:"description,omitempty"`
}
```

## 响应 DTO 标签

- 响应结构体必须显式指定 `json` 标签用于 API 输出。
- 可选或零值字段建议使用 `omitempty`，以便在 JSON 中适当省略空值。
- 字段命名保持一致（如 JSON 使用 snake_case 若为 API 约定）；在 OpenAPI 中说明响应结构。

## 函数与方法

- 动作用动词（CreateUser、ValidateEmail）。
- 示例：

```go
// 不良
func UserCreation(u User) error { return nil }

// 良好
func CreateUser(u User) error { return nil }
```

- 避免在方法名中重复接收者类型名。
- 示例：

```go
// 不良
func (u *User) UserValidateEmail() error { return nil }

// 良好
func (u *User) ValidateEmail() error { return nil }
```

- 函数名中不得重复包名（见命名）。

- 简单访问器避免 “Get” 前缀；使用名词化命名。
- 示例：

```go
// 不良
func (c *Config) GetJobName(key string) (string, bool) { return "", false }

// 良好
func (c *Config) JobName(key string) (string, bool) { return "", false }
```

- `error` 作为最后一个返回值。
- 示例：

```go
// 不良
func Load() (error, *Config) { return nil, nil }

// 良好
func Load() (*Config, error) { return nil, nil }
```

- 方法**修改接收者**、类型**较大**或为保持一致（若任一方法需指针）时，使用**指针接收者**；小且不可变类型使用**值接收者**。
- 大结构体或可能被修改时优先**传指针**；小类型或需避免意外修改时**传值**。

## 接口

- 接口按行为命名（如 `Reader`、`Repository`），不按实现（如避免 `ReaderInterface`）。尽量每个接口只有少量方法。
- 接口定义在**使用方**（如调用 repo 的 service），而不是实现处；见 `project_architecture.md`。

## Slice 与 nil

- nil slice 表示“无元素”；JSON 编码通常产生 `[]`。包内保持一致：要么返回 `nil` 要么返回 `[]T{}` 表示“无结果”；若无特殊需求，优先 `nil`。
- 示例：

```go
// 均可，包内选一种约定
func FindAll() []Item { return nil }
func FindAll() []Item { return []Item{} }
```

## 错误

- 用 `fmt.Errorf("context: %w", err)` 包装错误。
- 示例：

```go
// 不良
if err != nil {
    return fmt.Errorf("read config: %v", err)
}
// 服务层错误不得 panic
if err != nil {
  panic(err)
}


// 良好
if err != nil {
    return fmt.Errorf("read config: %w", err)
}

func (l *Logic) Operation() error {
    user, err := l.svcCtx.UserModel.FindOne(l.ctx, id)
    if err != nil {
        // 用上下文包装错误
        return fmt.Errorf("failed to find user %d: %w", id, err)
    }
    return nil
}
```

- 哨兵错误定义为 `var ErrNotFound = errors.New("not found")`。
- 示例：

```go
// 不良
func Find(id string) error {
    return errors.New("not found")
}

// 良好
var ErrNotFound = errors.New("not found")

func Find(id string) error {
    return ErrNotFound
}
```

- 使用 `errors.Is`/`errors.As`；避免字符串比较。
- 示例：

```go
// 不良
if err != nil && err.Error() == "not found" {
    return ErrNotFound
}

// 良好
if errors.Is(err, ErrNotFound) {
    return ErrNotFound
}
```

- 错误字符串小写，无句末标点。
- 示例：

```go
// 不良
var ErrNotFound = errors.New("Not Found.")

// 良好
var ErrNotFound = errors.New("not found")
```

- service 或 handler 中不得 panic；应返回错误。panic 仅在 `main`/init 或不可恢复的编程错误时可接受。
- 示例：

```go
// 不良（在 service/handler 中）
if err != nil {
    panic(err)
}

// 良好
if err != nil {
    return fmt.Errorf("operation: %w", err)
}
```

## 控制流与风格

- 优先卫语句；`return` 后避免 `else`。
- 示例：

```go
// 不良
if err != nil {
    return err
} else {
    return nil
}

// 良好
if err != nil {
    return err
}
return nil
```

- 避免深层嵌套；函数小而聚焦。
- 示例：

```go
// 不良
if ok {
    if err == nil {
        if ready {
            doWork()
        }
    }
}

// 良好
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

- 多分支逻辑优先 `switch`。
- 示例：

```go
// 不良
if status == "new" {
    handleNew()
} else if status == "done" {
    handleDone()
} else {
    handleOther()
}

// 良好
switch status {
case "new":
    handleNew()
case "done":
    handleDone()
default:
    handleOther()
}
```

- 除极短函数外避免裸 return。
- 示例：

```go
// 不良
func (s *Store) Find(id string) (u User, err error) {
    u, err = s.db.Get(id)
    if err != nil {
        return
    }
    return
}

// 良好
func (s *Store) Find(id string) (User, error) {
    u, err := s.db.Get(id)
    if err != nil {
        return User{}, err
    }
    return u, nil
}
```

## 注释

- 导出标识符必须有以标识符名开头的 godoc 注释。
- 示例：

```go
// 不良
// 处理用户存储
type UserStore struct{}

// 良好
// UserStore 处理用户存储。
type UserStore struct{}
```

- 注释解释“为什么”，而非“做什么”。
- 示例：

```go
// 不良
i++ // 自增 i

// 良好
i++ // 跳过哨兵值 0
```

- 移除过时注释；避免被注释掉的代码。
- 示例：

```go
// 不良
// 旧行为保留作参考
// doThingOld()

// 良好
// 用版本控制历史替代被注释掉的代码。
```

## Context 与并发

- 将 `context.Context` 作为请求作用域 API 的第一个参数。
- 示例：

```go
// 不良
func (s *Service) Do(userID string, ctx context.Context) error { return nil }

// 良好
func (s *Service) Do(ctx context.Context, userID string) error { return nil }
```

- 不要在结构体中存储 `context.Context`。
- 示例：

```go
// 不良
type Service struct {
    ctx context.Context
}

// 良好
type Service struct{}

func (s *Service) Do(ctx context.Context) error { return nil }
```

- Goroutine 必须有清晰的取消/退出路径，避免泄漏。
- 示例：

```go
// 不良
go func() {
    for {
        work()
    }
}()

// 良好
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

- 不要复制包含 `sync.Mutex`/`sync.WaitGroup` 的值。
- 示例：

```go
// 不良
type Counter struct {
    mu sync.Mutex
    n  int
}

func Copy(c Counter) Counter { // 会复制 mutex
    return c
}

// 良好
func Copy(c *Counter) *Counter { // 避免复制 mutex
    return c
}
```

- 用 `defer` 做清理（如 `defer f.Close()`、`defer mu.Unlock()`），确保所有返回路径执行，且与获取紧邻。

## 日志（风格）

- 在边界记录错误；避免在多层重复记录同一错误。
- 有结构化日志时优先使用 key-value 字段。

## 总结

### 始终要做

1. Handler 保持薄，逻辑集中在 service
2. 使用带上下文的结构化日志
3. 显式处理所有错误
4. 充分校验输入
5. 使用连接池
6. 对读多数据启用缓存
7. 编写单元测试
8. 原子操作使用事务
9. 监控生产指标
10. 对最佳实践或实现细节有疑问时，说明而不猜测
11. 遵循 RESTful API 设计原则与最佳实践

### 禁止做

1. 将业务逻辑放在 handler 中
2. 忽略错误
3. 在 handler 中创建连接
4. 循环中查询
5. 在生产中关闭弹性功能
6. 使用全局变量
7. 无超时阻塞
8. 创建无限 goroutine

## 参考资料

- Effective Go: <https://go.dev/doc/effective_go>
- Go Code Review Comments: <https://go.dev/wiki/CodeReviewComments>
- Google Go Style Guide: <https://google.github.io/styleguide/go/>
- Google Go Style Best Practices: <https://google.github.io/styleguide/go/best-practices>
