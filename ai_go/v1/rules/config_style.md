# Go Config Style

## Scope

This document defines annotation and documentation rules for Go configuration
structs and their corresponding YAML configuration files.

## Rule Levels

- MUST: mandatory
- SHOULD: recommended
- MAY: optional

## Rule 1: Enumerate All Valid Values for Enum/Multi-Option Fields

When a field accepts a fixed set of values, **MUST** list all valid options in
a trailing comment using `|` as separator.

```go
// GOOD
Driver string `mapstructure:"driver"` // "sqlite3" | "postgres"
Level  string `mapstructure:"level"`  // "debug" | "info" | "warn" | "error" | "fatal"
Mode   string `mapstructure:"mode"`   // "openldap" | "activedirectory"
SSLMode string `mapstructure:"sslmode"` // "disable" | "require" | "verify-ca" | "verify-full"

// BAD — missing valid values
Driver string `mapstructure:"driver"`
Level  string `mapstructure:"level"` // log level
```

## Rule 2: Annotate Complex Parameters with Units, Defaults, or Formats

Fields with units, default values, or special formats **MUST** include that
information in the comment.

```go
// GOOD
MaxSize    int    `mapstructure:"max_size"`  // max size per file in MB
MaxAge     int    `mapstructure:"max_age"`   // max days to retain old files
MaxBackups int    `mapstructure:"max_backups"` // max number of old files to retain (0 = unlimited)
Path       string `mapstructure:"path"`      // SQLite file path, e.g. "data/app.db"
DSN        string `mapstructure:"dsn"`       // e.g. "host=localhost port=5432 dbname=app"
Timeout    int    `mapstructure:"timeout"`   // connection timeout in seconds

// BAD — no units or examples
MaxSize int    `mapstructure:"max_size"`
Path    string `mapstructure:"path"`
Timeout int    `mapstructure:"timeout"`
```

## Rule 3: Sync Annotations to YAML Config Files

Valid values and explanations defined in Go structs **MUST** be mirrored as
comments in the corresponding YAML configuration file.

```yaml
# GOOD — valid values listed above the section, inline comments for units
# driver: sqlite3 | postgres
database:
  driver: sqlite3
  path: data/app.db            # SQLite file path

# level: debug | info | warn | error | fatal
# format: text | json
log:
  level: "info"
  format: "text"
  rotate:
    max_size: 100              # max size per file in MB
    max_age: 7                 # max days to retain old files
    max_backups: 0             # 0 = unlimited

# BAD — no comments
database:
  driver: sqlite3
log:
  level: "info"
  rotate:
    max_size: 100
```

## Rule 4: Struct-Level Comment for Config Sections

Each top-level config struct **SHOULD** have a brief godoc comment describing
its purpose.

```go
// GOOD
// DatabaseConfig holds database connection settings.
type DatabaseConfig struct {
    Driver  string `mapstructure:"driver"`  // "sqlite3" | "postgres"
    DSN     string `mapstructure:"dsn"`     // connection string
    SSLMode string `mapstructure:"sslmode"` // "disable" | "require" | "verify-ca" | "verify-full"
}

// BAD — no struct comment
type DatabaseConfig struct {
    Driver string `mapstructure:"driver"`
}
```

## Summary

| Situation | Requirement |
|---|---|
| Field with fixed set of values | List all with `\|` in trailing comment |
| Field with unit (MB, s, days) | State unit in comment |
| Field with special format | Provide example in comment |
| YAML config file | Mirror all Go struct annotations |
| Top-level config struct | Add godoc comment |
