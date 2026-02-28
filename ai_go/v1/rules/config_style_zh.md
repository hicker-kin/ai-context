# Go 配置风格

## 范围

本文档定义 Go 配置结构体及其对应 YAML 配置文件的注释与文档规范。

## 规则级别

- MUST（必须）：强制要求
- SHOULD（应该）：推荐
- MAY（可以）：可选

## Rule 1：枚举/多选值字段必须列出所有可选项

字段有固定可选值集合时，**MUST** 在行尾注释中用 `|` 分隔列出全部选项。

```go
// Good
Driver  string `mapstructure:"driver"`  // "sqlite3" | "postgres"
Level   string `mapstructure:"level"`   // "debug" | "info" | "warn" | "error" | "fatal"
Mode    string `mapstructure:"mode"`    // "openldap" | "activedirectory"
SSLMode string `mapstructure:"sslmode"` // "disable" | "require" | "verify-ca" | "verify-full"

// Bad — 缺少可选值
Driver string `mapstructure:"driver"`
Level  string `mapstructure:"level"` // 日志级别
```

## Rule 2：复杂参数必须注明单位、默认值或格式

含单位、默认值或特殊格式的字段，**MUST** 在注释中说明。

```go
// Good
MaxSize    int    `mapstructure:"max_size"`     // 单文件最大大小，单位 MB
MaxAge     int    `mapstructure:"max_age"`      // 旧文件最长保留天数
MaxBackups int    `mapstructure:"max_backups"`  // 旧文件最大保留份数（0 表示不限制）
Path       string `mapstructure:"path"`         // SQLite 文件路径，例如 "data/app.db"
DSN        string `mapstructure:"dsn"`          // 例如 "host=localhost port=5432 dbname=app"
Timeout    int    `mapstructure:"timeout"`      // 连接超时，单位秒

// Bad — 无单位、无示例
MaxSize int    `mapstructure:"max_size"`
Path    string `mapstructure:"path"`
Timeout int    `mapstructure:"timeout"`
```

## Rule 3：YAML 配置文件必须同步注释

Go 结构体中的可选值和参数说明，**MUST** 同步写到对应的 YAML 配置文件中。

```yaml
# Good — 段落上方列出可选值，行内注释说明单位
# driver: sqlite3 | postgres
database:
  driver: sqlite3
  path: data/app.db            # SQLite 文件路径

# level: debug | info | warn | error | fatal
# format: text | json
log:
  level: "info"
  format: "text"
  rotate:
    max_size: 100              # 单文件最大 MB
    max_age: 7                 # 保留天数
    max_backups: 0             # 0 表示不限制

# Bad — 无任何注释
database:
  driver: sqlite3
log:
  level: "info"
  rotate:
    max_size: 100
```

## Rule 4：顶层配置结构体应有 godoc 注释

每个顶层配置结构体 **SHOULD** 有简短的 godoc 注释，说明其用途。

```go
// Good
// DatabaseConfig 保存数据库连接配置。
type DatabaseConfig struct {
    Driver  string `mapstructure:"driver"`  // "sqlite3" | "postgres"
    DSN     string `mapstructure:"dsn"`     // 连接字符串
    SSLMode string `mapstructure:"sslmode"` // "disable" | "require" | "verify-ca" | "verify-full"
}

// Bad — 无结构体注释
type DatabaseConfig struct {
    Driver string `mapstructure:"driver"`
}
```

## 规则汇总

| 场景 | 要求 |
|---|---|
| 字段有固定可选值 | 用 `\|` 在行尾注释中列出全部选项 |
| 字段有单位（MB、秒、天） | 在注释中注明单位 |
| 字段有特殊格式 | 在注释中提供示例 |
| YAML 配置文件 | 同步 Go 结构体中的所有注释 |
| 顶层配置结构体 | 添加 godoc 注释 |
