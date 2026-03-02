# 项目架构

## 适用范围

本文档定义项目结构、分层、API 设计及依赖规则。基础代码风格见 `code_style.md`。

## Go 版本与模块

- **新项目**必须使用最低 Go 版本 **1.24+**，并在 `go.mod` 中设置（`go 1.24`）。**已有项目**除非用户明确要求，否则**禁止**升级 Go 版本。
- **模块路径**：优先清晰、便于 import 的路径（如 `github.com/org/repo`）；除非必要，避免在已提交的 `go.mod` 中使用 `replace`/`exclude`。
- 应用代码置于 **`internal/`**，避免被其他模块 import；可复用库放在 **`pkg/`**，供其他项目使用。
- 提交前执行 **`go mod tidy`**；不提交未跟踪或不必要的依赖。

## 核心原则

- 清晰的 Clean Architecture 分层边界。
- 接口驱动开发与显式依赖注入。
- 组合优于继承；小而专注的接口。
- 领域模型独立于传输与持久化。

## 推荐技术栈

无明确理由时，优先采用：

- **ORM**：优先 [ent](https://entgo.io/) 生成数据访问，放在 `internal/storage`（如 `internal/storage/databases/ent`）。仅在手动维护数据访问时使用 `internal/dao`。
- **Web 框架（HTTP）**：优先 [gin](https://github.com/gin-gonic/gin) 作为 HTTP 服务与路由；集成于 `internal/server/http` 和 `internal/router`。
- **日志**：优先 [zap](https://github.com/uber-go/zap) 做结构化日志；从 `pkg/log` 使用或注入到 handler/service。日志必须支持可配置的**落盘**与**日志切割**（按大小、时间或二者）；在配置中暴露（如 `configs/settings.yaml` 或 env），必要时在 `docs/design` 中说明。

如有项目约束或设计文档支撑，可使用其他技术选型。

## 项目初始化（Cobra）

需要**初始化新的 Go（CLI）项目**时，使用 Cobra-CLI 脚手架并遵循本节。

- **安装**（如未安装）：`go install github.com/spf13/cobra-cli@latest`
- **Init 并指定作者和许可证**：
  - `cobra-cli init -a "YourName <you@example.com>" -l mit`
  - 使用真实作者字符串；`-l mit` 表示 MIT 许可证。
- **指定模块路径的 Init**（需与 `go.mod` 一致）：
  - `cobra-cli init --pkg-name <module-path>`
  - 示例：`cobra-cli init --pkg-name gitlab.com/myapp/demo`
- **按需添加子命令**：
  - `cobra-cli add cache`
  - `cobra-cli add server`
  - `cobra-cli add migrate`
  - 根据项目需要添加其它命令（如 `version`、`run`）。

脚手架生成后，按以下**建议目录结构**调整（如添加或移动 `internal/`、`configs/` 等）。

## 建议目录结构

```shell
├── cmd/
│   ├── root.go
│   └── svr.go
├── configs/            # 配置文件
│   └── settings.yaml   # 默认配置（应用端口、DB 连接等）
├── deployments/        # 部署资源（Kubernetes YAML、Docker Compose）
│   ├── dev/
│   │   └── ...
│   └── prod/
│       └── ...
├── docs/               # 项目文档
│   ├── changelog/      # 变更日志（如 CHANGELOG.md）；SDD（规范驱动开发）及类似文档（如 ai_sdd）必须放此处
│   ├── design/         # 设计文档（PRD、架构图、约定、API 说明）；PRD 及类似设计文档必须放此处
│   └── swagger/        # OpenAPI/Swagger 规范（如 swagger.yaml）
├── internal/           # 私有应用代码（不可被 import）
│   ├── domain/         # 领域模型 / 实体（或 models/）
│   ├── dao/            # （可选）手动维护的数据访问；service 调用 dao
│   ├── server/         # 服务上下文
│   │   ├── grpc/       # grpc 服务
│   │   ├── http/       # http 服务
│   │   │   └── handler/   # 处理器（控制器）
│   │   │       ├── category.go
│   │   │       ├── flow.go
│   │   │       └── http.go
│   │   ├── server_i.go
│   │   └── svr.go
│   ├── infra/          # 基础设施：缓存、MQ、外部客户端；仅在 infra 不依赖其它 internal 包时被 service 使用
│   ├── router/         # 路由定义
│   └── service/        # 核心业务逻辑
│       ├── base.go
│       ├── category/
│       │   └── category.go
│       ├── dto/
│       │   └── category.go
│       ├── flow/
│           └── flow.go
├── pkg/                # 可复用共享库
│   ├── auth/
│   ├── log/
│   └── utils/
├── scripts/            # 构建/部署脚本
├── migrations/         # 数据库迁移
├── test/               # 集成/端到端测试
├── web/                # 前端资源（如适用）
├── .gitignore
├── Makefile            # 标准化构建命令
├── go.mod
├── go.sum
├── main.go             # 应用入口
└── README.md
```

- `internal/domain`（或 `models/`）—— 领域模型 / 实体。
- `internal/dao` ——（可选）手动维护的数据访问层；仅由 `service` 使用。使用 ent 等生成代码时可不使用。
- `internal/storage` ——（可选）生成的数据访问（如 `storage/databases/ent`）；仅由 `service` 使用。每个项目在 dao 与 storage 中选其一。
- `internal/handler`（或 `server/http/handler`、`server/grpc`）—— HTTP/gRPC 传输适配器；仅调用 service。
- `internal/infra` —— 缓存、MQ、外部客户端。仅当 infra 不依赖其它 internal 包时（见分层规则）可被 service 使用。
- `internal/router` —— 路由定义。
- `internal/service` —— 核心业务逻辑；`service/dto` 存放请求/响应 DTO。
- **docs/changelog** —— 变更日志与发布说明；**SDD（规范驱动开发）及类似文档**（如 ai_sdd）**必须**放在 `docs/changelog`。
- **docs/design** —— **PRD（产品需求文档）及其它设计文档**（架构图、约定、API 说明）**必须**放在 `docs/design`。所有项目文档统一置于 `docs/`。
- `configs`、`migrations`、`scripts`、`deployments`

## 分层与依赖规则

- **默认：依赖向内。** 外层可依赖同层或更内层；一般情形下内层不得 import 外层。
- **Handler 和 router** 不得直接 import 或调用 `dao`、`storage`、`domain` 或 `infra`；只能调用 **service** 层。**`internal/dao`**、**`internal/storage`**、**`internal/domain`** 仅由 `internal/service` 使用（或彼此以受控方式使用，如 dao 使用 domain 类型）。
- **例外（内层可依赖外层）：** 仅当该外层包**不依赖任何其它 internal 包**时，内层可依赖该外层包。例如，仅提供 cache/MQ 客户端、**不** import `service`、`dao` 或其它业务包时的 `internal/infra` 可被 `internal/service` 使用。外层包必须保持为“叶子”，无向内引用，以免形成循环。
- 禁止包之间循环依赖。

## API 设计

- 对端点做版本划分（`/v1`）并明确兼容保证。
- 定义标准错误响应格式（code、message、details、request_id）。
- 在 handler 中校验所有外部输入；映射为领域类型。
- 定义分页与过滤规则（limit、offset/cursor、sort）。
- gRPC 使用规范状态码与结构化错误详情。

## 可观测性

- 标准日志字段：request_id、trace_id、user_id、service、method、status。
- 指标：每个端点的请求数、延迟、错误率。
- 追踪：传播 context；每个入站请求一个 span。

## 健康检查

- 暴露 **存活**（如 `/healthz`）和 **就绪**（如 `/ready`）端点；分别用于 Kubernetes 的 `livenessProbe` 和 `readinessProbe`。
- **存活**：表示进程在运行。保持轻量、无依赖；失败时运行时可能重启 pod。
- **就绪**：表示应用能接受流量。可在此检查关键依赖（DB、Redis 等）。依赖不可用时返回非 2xx，pod 将从服务中摘除直至就绪。
- 在 `docs/design` 或 API 规范中说明 `/healthz` 和 `/ready` 的语义与状态码。

## 配置

- 从环境变量或配置文件加载配置；避免全局可变状态。
- 密钥不得提交；从密钥管理或 env 加载。

## 测试策略

- 对 infra 和 DB 访问做集成测试。
- 对公开 API 做契约测试。

## 安全

- 校验并净化所有外部输入。
- 鉴权/授权在边界（中间件/handler）处理。
- 避免记录敏感数据。

## 服务边界

- 每个服务拥有自己的数据与领域边界。
- 尽可能避免跨服务共享数据库。

## 🛠️ 技术栈

### Go 栈（主选）

Go 相关框架与常用库参考。

| 类别 | 组件 | 说明 / 用例 |
|----------|-----------|------------------------|
| **Web 框架** | [Gin](https://github.com/gin-gonic/gin) | 轻量 HTTP 路由、binding、中间件；广泛使用 |
| | [Echo](https://github.com/labstack/echo) | 带中间件、binding、良好 DX 的 HTTP 框架 |
| | [Kratos](https://github.com/go-kratos/kratos) | BFF/微服务框架；传输无关、DI、配置 |
| **ORM** | [ent](https://entgo.io/) | Schema 优先 ORM；代码生成、迁移、图遍历 |
| | [GORM](https://gorm.io/) | 约定型 ORM；迁移、hooks、多数据库 |
| **CLI / 应用引导** | [Cobra](https://github.com/spf13/cobra) | CLI 应用、子命令、flags |
| **调度** | [robfig/cron](https://github.com/robfig/cron) | 周期性任务 Cron 表达式 |
| **配置** | [Viper](https://github.com/spf13/viper) | 从文件、env、flags 读取配置；常与 Cobra 搭配 |
| **消息** | [IBM/sarama](https://github.com/IBM/sarama) | Kafka 客户端（生产者/消费者） |
| **日志** | [zap](https://github.com/uber-go/zap)、[zerolog](https://github.com/rs/zerolog) | 结构化、高性能日志 |
| **测试** | [testify](https://github.com/stretchr/testify) | 断言与 mock；[gomock](https://github.com/golang/mock) 生成 mock |
| **Redis** | [go-redis](https://github.com/redis/go-redis) | Redis 客户端；集群、哨兵、缓存、分布式锁 |
| **HTTP 客户端** | stdlib `net/http`、[resty](https://github.com/go-resty/resty) | 出站 HTTP；resty 便于使用与重试 |
| **弹性** | [golang.org/x/time/rate](https://pkg.go.dev/golang.org/x/time/rate)、[sentinel-golang](https://github.com/alibaba/sentinel-golang) | 限流；熔断与流控 |
| **追踪** | [OpenTelemetry Go](https://opentelemetry.io/docs/instrumentation/go/) | 分布式追踪；传播 context、导出 span |
| **迁移** | [golang-migrate](https://github.com/golang-migrate/migrate)、[atlas](https://atlasgo.io/) | DB schema 迁移；版本化 SQL 或声明式 |

### 语言与框架

下表为**通用参考**。**Go 项目**请遵循上表 **Go 栈（主选）** 及前述目录结构；此处仅作背景参考。

- **Java** - Spring Boot, Spring Security, JPA
- **Python** - FastAPI, Django, SQLAlchemy
- **Node.js** - Express, Koa, NestJS
- **Go** - Gin, Echo, GORM
- **Rust** - Actix-web, Rocket, Diesel

### 数据库

- **关系型** - PostgreSQL, MySQL
- **NoSQL** - MongoDB, Redis
- **搜索** - Elasticsearch
- **消息队列** - RabbitMQ, Kafka

### DevOps 与工具

- **容器化** - Docker, Kubernetes
- **CI/CD** - GitHub Actions, Jenkins
- **监控** - Prometheus, Grafana
- **日志** - ELK Stack

### 常用中间件参考

按类别列出主流中间件及典型用途（选型参考）。

| 类别 | 中间件 | 典型用途 | 说明 |
|----------|------------|------------------|-------|
| **关系型 DB** | MySQL | 主应用 DB、事务读写、OLTP | 生态成熟；主从与分片常见 |
| | PostgreSQL | 复杂查询、JSON、扩展类型、OLTP | 强一致性、丰富类型 |
| **分析型 DB** | ClickHouse | 日志/事件分析、实时报表、OLAP 宽表 | 列式、高压缩、适合聚合 |
| | StarRocks | 实时数仓、OLAP、湖仓一体、多表 JOIN | 兼容 MySQL 协议；实时摄取与分析 |
| **缓存** | Redis | 会话、热点缓存、分布式锁、限流、简单队列 | 单机/集群/哨兵；String/Hash/List 等 |
| | Memcached | 简单 KV 缓存、跨实例水平扩展 | 不需持久化时可选 |
| **消息队列** | Kafka | 日志摄取、事件流、数据管道、高吞吐解耦 | 分区、持久化、可重放 |
| | RabbitMQ | 任务队列、RPC、复杂路由、事务消息 | 灵活 exchange 与 binding |
| | RocketMQ | 订单/事务消息、有序与延迟消息 | 阿里系常用 |
| **搜索** | Elasticsearch | 全文搜索、日志搜索、APM、复杂聚合 | Lucene；适合搜索与日志 |
| **对象/Blob 存储** | MinIO / S3 | 图片、文件、备份、数据湖 | 对象存储；S3 兼容 API |

## 部署

### ✅ Docker

```dockerfile
# Dockerfile
FROM golang:1.24-alpine AS builder

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
9. 实施适当安全措施
10. 监控生产指标
11. 对最佳实践或实现细节有疑问时，说明而不猜测
12. 遵循 RESTful API 设计原则与最佳实践
13. 每次业务逻辑变更，**必须**检查 `docs/design` 并更新或补充设计文档

### 禁止做

1. 将业务逻辑放在 handler 中
2. 记录敏感信息
3. 忽略错误
4. 在 handler 中创建连接
5. 循环中查询
6. 在生产中关闭弹性功能
7. 使用全局变量
8. 无超时阻塞
9. 创建无限 goroutine
10. 未校验就信任用户输入

## 参考资料

- 框架：<https://gitee.com/czsuccess/rules-2.1-optimized-zh/blob/master/%E9%A1%B9%E7%9B%AE%E8%A7%84%E5%88%99/backend-dev.mdc>
