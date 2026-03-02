# Go HTTP Response Format

## Scope

This document defines the standard HTTP response structures and JSON tag rules
for all handler-layer responses. Architecture and layering rules are in
`project_architecture.md`.

## Rule Levels

- MUST: mandatory
- SHOULD: recommended
- MAY: optional

## Rule 1: Standard Response Wrapper

All HTTP handler responses **MUST** use `HTTPResponse` as the top-level
response envelope when returning a generic/untyped response.

The following constants **MUST** be used for successful responses:

```go
const (
    CodeOK = "0"
    MsgOK  = "ok"
)
```

```go
// GOOD — standard envelope
type HTTPResponse struct {
    Code      string            `json:"code"`
    Msg       string            `json:"message"`
    Data      any               `json:"result,omitempty"`
    Details   map[string]string `json:"details,omitempty"`
    RequestID string            `json:"request_id,omitempty"`
}
```

Field semantics:

| Field     | Type               | JSON key       | Notes                                          |
|-----------|--------------------|----------------|------------------------------------------------|
| Code      | string             | code           | Business status code; use `CodeOK = "0"` for success |
| Msg       | string             | message        | Human-readable description                     |
| Data      | any                | result         | Business payload; omitted when nil/empty        |
| Details   | map[string]string  | details        | Field-level error map; omitted when nil         |
| RequestID | string             | request_id     | Trace/request ID; omitted when empty            |

## Rule 2: Typed Response — BaseResponse Embedding

For typed, endpoint-specific responses, **MUST** embed `BaseResponse` and
declare a `Result` field with an explicit `json:"result"` tag.

```go
// GOOD — BaseResponse holds the common fields
type BaseResponse struct {
    Code      string `json:"code"`
    RequestID string `json:"request_id,omitempty"`
}

// GOOD — typed single-item response
type FormTemplateResp struct {
    BaseResponse
    Result *FormTemplate `json:"result"`
}

// GOOD — typed paginated response
type FormTemplatePageResp struct {
    BaseResponse
    Result *FormTemplatePageData `json:"result"`
}
```

```go
// BAD — mixes envelope fields ad-hoc instead of embedding BaseResponse
type FormTemplateResp struct {
    Code   string        `json:"code"`
    Msg    string        `json:"message"`
    Data   *FormTemplate // ❌ missing json tag
    ReqID  string        // ❌ missing json tag, inconsistent field name
}
```

## Rule 3: Pagination Wrapper

All paginated response payloads **MUST** use the `Pagination` struct and name
the JSON field `"pagination"`.

```go
// GOOD — pagination wrapper
type Pagination struct {
    Total    int `json:"total"`
    PageSize int `json:"page_size"`
    Current  int `json:"current"`
}

// GOOD — paginated page data
type FormTemplatePageData struct {
    Page Pagination      `json:"pagination"`
    List []*FormTemplate `json:"list"`
}
```

```go
// BAD — custom pagination fields without the standard struct
type FormTemplatePageData struct {
    TotalCount int             // ❌ no json tag, non-standard field name
    Size       int             // ❌ no json tag, non-standard field name
    Page       int             // ❌ no json tag, ambiguous name
    Items      []*FormTemplate `json:"items"` // ❌ non-standard key (use "list")
}
```

## Rule 4: Explicit JSON Tags — No Defaults Allowed

Every field in a response struct **MUST** have an explicit `json` tag. Using
default (implicit) JSON field names derived from the Go identifier is forbidden.

```go
// GOOD — every field has an explicit json tag
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
// BAD — fields without json tags; serialized names are Go field names
type OrderDetail struct {
    OrderID    string // ❌ serializes as "OrderID" (PascalCase leak)
    UserID     string // ❌ serializes as "UserID"
    TotalPrice int64  // ❌ serializes as "TotalPrice"
    Status     string `json:"status"` // only this one is correct
}
```

## Rule 5: Use `omitempty` Consistently

- Optional envelope fields (`Details`, `RequestID`, `Data`) **MUST** use `omitempty`.
- Required payload fields (e.g. `Code`, `Msg`) **MUST NOT** use `omitempty`.
- Inner DTO fields: use `omitempty` only when the zero value is semantically
  meaningful (e.g. optional query filters); otherwise omit `omitempty` to keep
  the response shape stable.

```go
// GOOD
type HTTPResponse struct {
    Code      string            `json:"code"`             // always present
    Msg       string            `json:"message"`          // always present
    Data      any               `json:"result,omitempty"` // absent when nil
    Details   map[string]string `json:"details,omitempty"`
    RequestID string            `json:"request_id,omitempty"`
}

// BAD — Code omitted when empty string; consumers lose required field
type HTTPResponse struct {
    Code string `json:"code,omitempty"` // ❌ required field with omitempty
    Msg  string `json:"message"`
}
```

## Summary

| Situation                           | Requirement                                                     |
|-------------------------------------|-----------------------------------------------------------------|
| Generic handler return              | Use `HTTPResponse` envelope                                     |
| Typed endpoint response             | Embed `BaseResponse`; declare `Result` with `json:"result"`     |
| Paginated payload                   | Use `Pagination` struct; name field `json:"pagination"`         |
| Every response struct field         | MUST have explicit `json` tag; default names are forbidden      |
| Optional envelope fields            | MUST use `omitempty`                                            |
| Required fields (`code`, `message`) | MUST NOT use `omitempty`                                        |
