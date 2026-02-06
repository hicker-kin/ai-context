# Project Architecture

## Scope
This document defines project structure, layering, API design, and dependency
rules. Base code style is defined in `code_style.md`.

## Go Version and Module
- Use a **minimum Go version** (e.g. 1.21+) and set it in `go.mod` (`go 1.21`).
- **Module path**: Prefer a clear, import-friendly path (e.g. `github.com/org/repo`); avoid `replace`/`exclude` in committed `go.mod` unless necessary.
- Keep application code under **`internal/`** so it is not importable by other modules; put reusable libraries under **`pkg/`** if they may be used by other projects.
- Run **`go mod tidy`** before committing; do not commit untracked or unnecessary dependencies.

## Core Principles
- Clean Architecture with clear layer boundaries.
- Interface-driven development and explicit dependency injection.
- Composition over inheritance; small, purpose-specific interfaces.
- Domain models are independent of transport and persistence concerns.

## Suggested Directory Layout

```shell
├── cmd/
│   ├── root.go
│   └── svr.go
├── configs/            # configuration files
│   └── settings.yaml   # default config (app port, DB connection, etc.)
│
├── deployments/        # deployment assets (Kubernetes YAML, Docker Compose)
│   ├── dev/
│   │   └── ...
│   └── prod/
│       └── ...
├── docs/               # project docs
│   ├── changelog/      # changelog (e.g. CHANGELOG.md per release/iteration)
│   ├── design/         # design docs (diagrams, conventions, API notes)
│   └── swagger/        # OpenAPI/Swagger specs (e.g. swagger.yaml)
├── internal/           # private application code (not importable)
│   ├── domain/         # domain models
│   ├── handler/        # controller.
│   ├── infra/          # infrastructure (DB, cache, MQ)
│   ├── router/         # routing definitions
│   ├── service/        # core business logic
│   └── service/dto/    # DTOs for DO/VO conversion
├── pkg/                # reusable shared libraries
│   ├── auth/
│   ├── log/
│   └── utils/
├── scripts/            # build/deploy scripts
├── migrations/         # database migrations
├── test/               # integration/end-to-end tests
├── web/                # frontend assets (if applicable)
├── .gitignore
├── Makefile            # standardized build commands
├── go.mod
├── go.sum
├── main.go             # main application entrypoint
└── README.md
```

- `internal/handler` - HTTP/gRPC transport adapters
- `internal/infra` - cache, MQ, external clients
- `configs`, `migrations`, `scripts`, `deployments`

## Layering and Dependency Rules
- Dependencies MUST go inward: an outer layer may depend on the same layer or a
  deeper layer; inner layers MUST NOT import outer layers.
- **`internal/infra` and other internal packages** (e.g. `domain`, repo implementations)
  **MUST only be used by `internal/service`.** Handlers and router must not import or
  call infra, domain, or repositories directly; they call the service layer only.
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

## Health Checks
- Expose **liveness** (e.g. `/healthz`) and **readiness** (e.g. `/ready`) endpoints; use them in Kubernetes `livenessProbe` and `readinessProbe` respectively.
- **Liveness**: Indicates the process is running. Keep it cheap and dependency-free; if it fails, the runtime may restart the pod.
- **Readiness**: Indicates the app can accept traffic. Here you MAY check critical dependencies (DB, Redis, etc.). If a dependency is down, return non-2xx so the pod is removed from service until it is ready again.
- Document the exact semantics and status codes of `/healthz` and `/ready` (e.g. in `docs/design` or API spec).

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

## 🛠️ Technology Stack

### Go Stack (primary)

Go-focused frameworks and common libraries for reference.

| Category | Component | Description / use case |
|----------|-----------|------------------------|
| **Web framework** | [Gin](https://github.com/gin-gonic/gin) | Lightweight HTTP router, binding, middleware; widely used |
| | [Echo](https://github.com/labstack/echo) | HTTP framework with middleware, binding, and good DX |
| | [Kratos](https://github.com/go-kratos/kratos) | BFF/microservice framework; transport-agnostic, DI, config |
| **ORM** | [ent](https://entgo.io/) | Schema-first ORM; codegen, migrations, graph traversal |
| | [GORM](https://gorm.io/) | Convention-based ORM; migrations, hooks, many DBs |
| **CLI / app bootstrap** | [Cobra](https://github.com/spf13/cobra) | CLI apps, subcommands, flags |
| **Scheduling** | [robfig/cron](https://github.com/robfig/cron) | Cron expressions for periodic jobs |
| **Config** | [Viper](https://github.com/spf13/viper) | Config from files, env, flags; often used with Cobra |
| **Messaging** | [IBM/sarama](https://github.com/IBM/sarama) | Kafka client (producer/consumer) |
| **Logging** | [zap](https://github.com/uber-go/zap), [zerolog](https://github.com/rs/zerolog) | Structured, high-performance logging |
| **Testing** | [testify](https://github.com/stretchr/testify) | Assertions and mocks; [gomock](https://github.com/golang/mock) for generated mocks |
| **Redis** | [go-redis](https://github.com/redis/go-redis) | Redis client; cluster, sentinel, cache, distributed lock |
| **HTTP client** | stdlib `net/http`, [resty](https://github.com/go-resty/resty) | Outbound HTTP; resty for convenience and retries |
| **Resilience** | [golang.org/x/time/rate](https://pkg.go.dev/golang.org/x/time/rate), [sentinel-golang](https://github.com/alibaba/sentinel-golang) | Rate limiting; circuit breaker and flow control |
| **Tracing** | [OpenTelemetry Go](https://opentelemetry.io/docs/instrumentation/go/) | Distributed tracing; propagate context and export spans |
| **Migrations** | [golang-migrate](https://github.com/golang-migrate/migrate), [atlas](https://atlasgo.io/) | DB schema migrations; versioned SQL or declarative |

### Languages & Frameworks

The list below is a **general reference** across stacks. For **Go projects**, follow the **Go Stack (primary)** table and the directory layout above; the entries here are for context only.

- **Java** - Spring Boot, Spring Security, JPA
- **Python** - FastAPI, Django, SQLAlchemy
- **Node.js** - Express, Koa, NestJS
- **Go** - Gin, Echo, GORM
- **Rust** - Actix-web, Rocket, Diesel

### Databases
- **Relational** - PostgreSQL, MySQL
- **NoSQL** - MongoDB, Redis
- **Search** - Elasticsearch
- **Message Queue** - RabbitMQ, Kafka

### DevOps & Tools
- **Containerization** - Docker, Kubernetes
- **CI/CD** - GitHub Actions, Jenkins
- **Monitoring** - Prometheus, Grafana
- **Logging** - ELK Stack

### Common Middleware Reference

Common mainstream middleware by category and typical use cases (for reference when choosing components).

| Category | Middleware | Typical use cases | Notes |
|----------|------------|------------------|-------|
| **Relational DB** | MySQL | Primary app DB, transactional read/write, OLTP | Mature ecosystem; master-replica and sharding common |
| | PostgreSQL | Complex queries, JSON, extended types, OLTP | Strong consistency and rich types |
| **Analytical DB** | ClickHouse | Log/event analytics, real-time reporting, OLAP wide tables | Columnar, high compression, good for aggregations |
| | StarRocks | Real-time data warehouse, OLAP, lakehouse, multi-table JOIN | MySQL-protocol compatible; real-time ingest and analytics |
| **Cache** | Redis | Session, hot-data cache, distributed lock, rate limit, simple queues | Standalone/cluster/sentinel; String/Hash/List etc. |
| | Memcached | Simple KV cache, horizontal scaling across instances | Option when persistence not required |
| **Message Queue** | Kafka | Log ingestion, event streaming, data pipelines, high-throughput decoupling | Partitioning, persistence, replay |
| | RabbitMQ | Task queues, RPC, complex routing, transactional messages | Flexible exchanges and bindings |
| | RocketMQ | Order/transaction messages, ordered and delayed messages | Common in Alibaba ecosystem |
| **Search** | Elasticsearch | Full-text search, log search, APM, complex aggregations | Lucene-based; suited for search and logging |
| **Object / Blob storage** | MinIO / S3 | Images, files, backups, data lake storage | Object storage; S3-compatible API |

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
13. For every business logic change, MUST check `docs/design` and update or add
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


## References
- Frameworks: https://gitee.com/czsuccess/rules-2.1-optimized-zh/blob/master/%E9%A1%B9%E7%9B%AE%E8%A7%84%E5%88%99/backend-dev.mdc