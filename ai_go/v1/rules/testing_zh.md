# Go 测试规则

## 适用范围

Go 服务的实践性测试约定。与 `project_architecture.md`（分层）及 `code_style.md`（格式/命名）配套使用。

## 核心必须项（MUST）

- 使用表驱动测试，子测试按场景命名（如 `missing_email`、`not_found`）。
- 辅助函数调用 `t.Helper()`。
- 测试要确定性的：固定随机种子，不依赖墙上时钟。
- 覆盖错误与边界情况；验证行为与返回错误。
- 限制资源：`context.WithTimeout`、`t.Cleanup` 做清理。
- 仅在边界记录日志；优先断言而非打印。
- 对 infra 的集成/契约测试，确保数据隔离与清理。

## 良好 / 不良示例

### 表驱动 + gomock + 超时（良好）

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

### 非确定性且无结构（不良）

```go
func TestRand(t *testing.T) {
    r := rand.New(rand.NewSource(time.Now().UnixNano())) // 非确定性 ❌
    if r.Intn(2) == 0 {
        t.Fatal("flaky") // 无场景名、无结构 ❌
    }
}
```

### 缺少清理且未覆盖边界（不良）

```go
func TestRepo(t *testing.T) {
    repo := newRepo() // 无清理 ❌
    _ = repo.Save(context.Background(), "id", "value") // 未检查错误 ❌
}
```

## 集成 / 契约测试

- 隔离数据（独立 DB/schema 或测试租户）。
- 使用会清理的工厂/fixture；优先 `t.Cleanup`。
- 避免共享全局状态；注入依赖。
- 对公开 API 断言外部形态（状态码、响应体结构、错误码）。

## 基准测试

- 使用 `b.ReportAllocs()`，用稳定输入运行，setup 避免在循环内分配。
- 并行基准使用正确的同步；避免测量无关工作。
