# Logging Usage Examples

Reference: workflowx `internal/service/category/category.go`.

## Service Constructor (inject logger)

```go
type categoryBll struct {
    cli    *ent.CategoryClient
    logger *zap.Logger
}

func NewCategoryBll(cli *ent.CategoryClient, logger *zap.Logger) Service {
    return &categoryBll{cli: cli, logger: logger}
}
```

## Request-scoped: WithRequestID

At the start of each method that has request context:

```go
func (c categoryBll) Create(ctx context.Context, req dto.CreateCategoryReq) (*dto.CategoryVOResp, error) {
    logger := log.WithRequestID(ctx, c.logger)
    // ... use logger for all logs in this method
}
```

## Error logging

```go
su, err := utils.GetSessionUserByToken(request.GetToken(ctx))
if err != nil {
    logger.Error("get session user failed", zap.Error(err))
    return nil, err
}
```

## Info with structured fields

```go
logger.Info("create category", zap.Any("req", req))

logger.Info("create category success",
    zap.String("id", save.ID),
    zap.String("name", save.Name))
```

## Warn (validation failure)

```go
if err := c.validateCreateRequest(ctx, req); err != nil {
    logger.Warn("create category validation failed", zap.Error(err))
    return nil, err
}
```

## List/count logging

```go
logger.Info("list category", zap.Any("req", req))
// ... query count
logger.Info("list category count", zap.Int("count", count))
```

## Delete with context fields

```go
logger := log.WithRequestID(ctx, c.logger)
logger.Info("delete category",
    zap.String("user_id", su.ID),
    zap.String("id", id))
```
