# Go 安全规则

## 适用范围

Go 服务中的输入处理、鉴权授权、数据保护及日志实践。

## 核心必须项（MUST）

- 校验并净化所有外部输入；使用框架校验器（`binding`、`validator`）及明确的 `json` 标签。
- 在边界处（中间件/处理器）强制认证（AuthN）/授权（AuthZ）；处处遵循最小权限原则。
- 使用参数化查询 / 预编译语句；禁止 SQL 字符串拼接。
- 转义/编码模板输出；除非明确需要，避免不安全的 HTML。
- 不得记录密钥、令牌、密码或 PII；记录前先脱敏。
- 从环境变量/密钥存储加载密钥；禁止提交到版本库。
- 对公开端点及出站调用适当添加限流 / 熔断。
- 保持依赖更新；定期执行漏洞扫描。

## 良好 / 不良示例

### 安全 DB 查询 + 授权 + 无敏感日志（良好）

```go
if !rbac.Allowed(user, "order:read") {
    return ErrForbidden
}
row := db.QueryRowContext(ctx, "SELECT id, amount FROM orders WHERE id = ?", id)
if err := row.Scan(&o.ID, &o.Amount); err != nil {
    return fmt.Errorf("query order %d: %w", id, err)
}
logger.Info("order fetched", "user_id", user.ID, "order_id", id) // 无 PII ✅
```

### SQL 注入 + 密钥泄露（不良）

```go
q := fmt.Sprintf("SELECT * FROM orders WHERE id = %s", id) // 注入 ❌
logger.Infof("token=%s", token)                            // 泄露密钥 ❌
```

## 输入与输出

- 校验长度、格式和枚举；尽早拒绝并返回清晰错误。
- 可选字段使用 `omitempty`；避免用隐式默认值掩盖错误。
- 模板中使用 `html/template` 自动转义输出；对不可信数据避免使用 `text/template`。

## 传输与存储

- 所有网络流量使用 TLS；调用外部服务时校验证书。
- 密码使用加盐哈希存储（如 bcrypt/argon2）；禁止可逆存储。
- 定期轮换凭据；优先使用短期令牌。

## 日志与监控

- 集中使用结构化日志；包含 request_id/trace_id。
- 避免在多层重复记录同一错误。
- 监控认证失败、限流触发及异常访问模式。
- 禁止记录密钥、令牌、密码、PII；避免循环中产生噪音日志；服务中避免 `fmt.Println`/`log.Println`。

### 日志反模式（不良）与更安全做法（良好）

```go
// 不良：敏感数据
logger.Infof("user password: %s", password)  // ❌
logger.Infof("auth token: %s", token)        // ❌

// 不良：噪音循环
for _, item := range items {
    logger.Infof("processing %v", item) // ❌ 过于冗长
}

// 不良：临时打印（无结构、无脱敏）
fmt.Println("debug info") // ❌

// 良好：汇总、结构化、无敏感信息
logger.Info("batch processed", "count", len(items))
```

## 防御性控制

- 对入站处理器应用限流和超时。
- 仅对幂等出站调用添加带退避的重试；限制重试次数。
- 所有网络与存储调用均使用 context 超时。
