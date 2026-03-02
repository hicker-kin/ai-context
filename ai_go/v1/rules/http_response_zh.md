# Go HTTP 响应格式规范

## 适用范围

本文档定义所有 handler 层 HTTP 响应结构体和 JSON tag 的统一规范。
架构分层规则参见 `project_architecture.md`。

## 规则等级

- MUST：强制
- SHOULD：推荐
- MAY：可选

## 规则 1：标准响应包装体

所有 HTTP handler 返回通用/无类型响应时，**MUST** 使用 `HTTPResponse` 作为
顶层响应包装体。

成功响应的 Code 和 Msg **MUST** 使用以下预定义常量：

```go
const (
    CodeOK = "0"
    MsgOK  = "ok"
)
```

```go
// GOOD — 标准包装体
type HTTPResponse struct {
    Code      string            `json:"code"`
    Msg       string            `json:"message"`
    Data      any               `json:"result,omitempty"`
    Details   map[string]string `json:"details,omitempty"`
    RequestID string            `json:"request_id,omitempty"`
}
```

字段说明：

| 字段      | 类型               | JSON key       | 说明                                      |
|-----------|--------------------|----------------|-------------------------------------------|
| Code      | string             | code           | 业务状态码，成功用 `CodeOK = "0"`          |
| Msg       | string             | message        | 人类可读的描述信息                         |
| Data      | any                | result         | 业务数据，nil/空时省略                     |
| Details   | map[string]string  | details        | 字段级错误映射，nil 时省略                 |
| RequestID | string             | request_id     | 链路追踪/请求 ID，空时省略                 |

## 规则 2：类型化响应 — 嵌入 BaseResponse

针对具体接口的类型化响应，**MUST** 嵌入 `BaseResponse`，并显式声明
带有 `json:"result"` tag 的 `Result` 字段。

```go
// GOOD — BaseResponse 持有公共字段
type BaseResponse struct {
    Code      string `json:"code"`
    RequestID string `json:"request_id,omitempty"`
}

// GOOD — 单条记录响应
type FormTemplateResp struct {
    BaseResponse
    Result *FormTemplate `json:"result"`
}

// GOOD — 分页响应
type FormTemplatePageResp struct {
    BaseResponse
    Result *FormTemplatePageData `json:"result"`
}
```

```go
// BAD — 临时拼凑字段，未嵌入 BaseResponse
type FormTemplateResp struct {
    Code   string        `json:"code"`
    Msg    string        `json:"message"`
    Data   *FormTemplate // ❌ 缺少 json tag
    ReqID  string        // ❌ 缺少 json tag，字段名不一致
}
```

## 规则 3：分页包装体

所有分页响应的数据体，**MUST** 使用 `Pagination` 结构体，并将
JSON 字段名设为 `"pagination"`。

```go
// GOOD — 分页结构体
type Pagination struct {
    Total    int `json:"total"`
    PageSize int `json:"page_size"`
    Current  int `json:"current"`
}

// GOOD — 分页数据体
type FormTemplatePageData struct {
    Page Pagination      `json:"pagination"`
    List []*FormTemplate `json:"list"`
}
```

```go
// BAD — 自定义分页字段，未使用标准结构体
type FormTemplatePageData struct {
    TotalCount int             // ❌ 无 json tag，字段名非标准
    Size       int             // ❌ 无 json tag，字段名非标准
    Page       int             // ❌ 无 json tag，语义不清
    Items      []*FormTemplate `json:"items"` // ❌ key 非标准（应使用 "list"）
}
```

## 规则 4：JSON Tag 必须显式声明，禁止使用默认 Tag

响应结构体的每个字段，**MUST** 显式声明 `json` tag。
禁止依赖 Go 字段名作为默认 JSON 序列化名称。

```go
// GOOD — 每个字段均有显式 json tag
type OrderResp struct {
    BaseResponse
    Result *OrderDetail `json:"result"`
}

type OrderDetail struct {
    OrderID    string `json:"order_id"`
    UserID     string `json:"user_id"`
    TotalPrice int64  `json:"total_price"`
    Status     string `json:"status"`
}
```

```go
// BAD — 字段无 json tag，序列化后为 Go 字段名（PascalCase 泄漏）
type OrderDetail struct {
    OrderID    string // ❌ 序列化为 "OrderID"
    UserID     string // ❌ 序列化为 "UserID"
    TotalPrice int64  // ❌ 序列化为 "TotalPrice"
    Status     string `json:"status"` // 仅此字段正确
}
```

## 规则 5：omitempty 使用规范

- 可选的包装体字段（`Details`、`RequestID`、`Data`）**MUST** 使用 `omitempty`。
- 必填字段（如 `Code`、`Msg`）**MUST NOT** 使用 `omitempty`。
- 内层 DTO 字段：仅当零值有业务语义时使用 `omitempty`，
  否则不加，以保持响应结构稳定。

```go
// GOOD
type HTTPResponse struct {
    Code      string            `json:"code"`             // 必填，始终输出
    Msg       string            `json:"message"`          // 必填，始终输出
    Data      any               `json:"result,omitempty"` // nil 时省略
    Details   map[string]string `json:"details,omitempty"`
    RequestID string            `json:"request_id,omitempty"`
}

// BAD — Code 为必填字段，不应使用 omitempty
type HTTPResponse struct {
    Code string `json:"code,omitempty"` // ❌ 必填字段加了 omitempty
    Msg  string `json:"message"`
}
```

## 规则速查表

| 场景                             | 要求                                                        |
|----------------------------------|-------------------------------------------------------------|
| 通用 handler 返回                | 使用 `HTTPResponse` 包装体                                  |
| 类型化接口响应                   | 嵌入 `BaseResponse`；`Result` 字段用 `json:"result"`        |
| 分页数据体                       | 使用 `Pagination` 结构体；字段名用 `json:"pagination"`      |
| 响应结构体所有字段               | MUST 显式声明 json tag；禁止使用默认序列化名                |
| 可选包装体字段                   | MUST 使用 `omitempty`                                       |
| 必填字段（code、message）        | MUST NOT 使用 `omitempty`                                   |
