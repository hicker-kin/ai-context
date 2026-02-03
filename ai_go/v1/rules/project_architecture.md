# Project Architecture

## Scope
This document defines project structure, layering, API design, and dependency
rules. Base code style is defined in `code_style.md`.

## Core Principles
- Clean Architecture with clear layer boundaries.
- Interface-driven development and explicit dependency injection.
- Composition over inheritance; small, purpose-specific interfaces.
- Domain models are independent of transport and persistence concerns.

## Suggested Directory Layout

```shell
├── cmd/               
│   └── root.go
│   └── svr.go
├── configs/            # 配置文件
│   └── settings.yaml   # 默认配置文件（如应用端口、DB连接等）
│
├── deployments/        # 部署相关（如 Kubernetes YAML、Docker Compose）
│   ├── dev/
│   │   └── ...
│   └── prod/
│       └── ...
├── docs/               # 项目文档
├── ├── changelog/      # 变更日志（如 CHANGELOG.md，每次发布/迭代记录重要变更）
│   ├── design/         # 设计文档（流程图、协作约定、接口说明等）
│   └── swagger/        # OpenAPI/Swagger 规范，API 文档生成 (如 swagger.yaml)
├── internal/           # 私有应用代码（不可被外部导入）
│   ├── domain/         # 领域模型
│   ├── handler/        # controller.
│   ├── router/         # 路由定义
│   ├── service/        # 应用核心业务逻辑
│   └── service/dto/    # 数据传输对象，用于do 和 vo的相互转换
├── pkg/                # 可重用的公共库代码
│   ├── auth/
│   ├── log/
│   └── utils/
├── scripts/            # 构建/部署脚本
├── migrations/         # 数据库迁移
├── test/               # 集成/端到端测试
├── web/                # 前端资源（如果适用）
├── .gitignore
├── Makefile            # 标准化构建命令
├── go.mod
├── go.sum
├── main.go             # 主应用程序入口
└── README.md
```

- `internal/handler` - HTTP/gRPC transport adapters
- `internal/infra` - cache, MQ, external clients
- `configs`, `migrations`, `scripts`, `deployments`

## Layering and Dependency Rules
- Dependencies MUST go inward: an outer layer may depend on the same layer or a
  deeper layer; inner layers MUST NOT import outer layers.
- Cyclic dependencies between packages are forbidden.

## API Design
- Version endpoints (`/v1`) and document compatibility guarantees.
- Define a standard error response shape (code, message, details, request_id).
- Validate all external input in handlers; map to domain types.
- Define pagination and filtering rules (limit, offset/cursor, sort).
- For gRPC, use canonical status codes and structured error details.

## Observability
- Standard log fields: request_id, trace_id, user_id, service, method, status.
- Metrics: request count, latency, error rate for each endpoint.
- Tracing: propagate context; span per inbound request.

## Configuration
- Config from environment or config files; avoid global mutable state.
- Secrets are never committed; load from secret managers or env.

## Testing Strategy
- Integration tests for `infra` and DB access.
- Contract tests for public APIs.

## Security
- Validate and sanitize all external inputs.
- AuthN/AuthZ handled at the boundary (middleware/handler).
- Avoid logging sensitive data.

## Service Boundaries
- Each service owns its data and domain boundary.
- Avoid shared databases across services when possible.

## Deployment

### ✅ Docker

```dockerfile
# Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o service .

FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app
COPY --from=builder /app/service .
COPY --from=builder /app/etc ./etc

EXPOSE 8888
CMD ["./service", "-f", "etc/config.yaml"]
```

### ✅ Kubernetes

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-api
  template:
    metadata:
      labels:
        app: user-api
    spec:
      containers:
      - name: user-api
        image: user-api:latest
        ports:
        - containerPort: 8888
        env:
        - name: USER_API_MODE
          value: "pro"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8888
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8888
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: user-api
spec:
  selector:
    app: user-api
  ports:
  - port: 8888
    targetPort: 8888
  type: ClusterIP
```

## Summary

### Always Do:
1. Keep handlers thin, logic thick
2. Use structured logging with context
3. Handle all errors explicitly
4. Validate input thoroughly
5. Use connection pooling
6. Enable caching for read-heavy data
7. Write unit tests
8. Use transactions for atomic operations
9. Implement proper security measures
10. Monitor production metrics
11. If unsure about a best practice or implementation detail, say so instead of guessing
12. Follow RESTful API design principles and best practices
13. For every business logic change, check `docs/design` and update or add
    design documentation as needed

### Never Do:
1. Put business logic in handlers
2. Log sensitive information
3. Ignore errors
4. Create connections in handlers
5. Query in loops
6. Disable resilience features in production
7. Use global variables
8. Block without timeouts
9. Create unbounded goroutines
10. Trust user input without validation
