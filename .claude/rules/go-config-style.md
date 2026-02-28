---
description: Go config struct and YAML file annotation rules
paths:
  - "**/config*.go"
  - "**/config*.yaml"
  - "**/config*.yml"
---

# Config Annotation Rules (MUST follow)

Follow the full rules in:

- `@ai_go/v1/rules/config_style.md`
- `@.ai-context/rules/config_style.md`
- `@.ai-context/rules/config_style_zh.md` (中文版)
- `@ai_go/v1/rules/config_style_zh.md` (中文版)

配置结构体和配置文件**必须**保持注释同步。

## Key MUSTs

- 枚举/多选值：**MUST** 在行尾注释中用 `|` 分隔列出全部可选项。
- 复杂参数：**MUST** 在注释中说明单位、默认值或特殊格式。
- YAML 同步：Go 结构体中的可选值和说明，**MUST** 同步写到 YAML 配置文件中。

```go
// Good
Driver string `mapstructure:"driver"` // "sqlite3" | "postgres"
Level  string `mapstructure:"level"`  // "debug" | "info" | "warn" | "error" | "fatal"
MaxSize int    `mapstructure:"max_size"` // max size per file in MB
Path    string `mapstructure:"path"`    // SQLite file path, e.g. "data/app.db"

// Bad
Driver  string `mapstructure:"driver"`
Level   string `mapstructure:"level"`   // log level
MaxSize int    `mapstructure:"max_size"`
```
