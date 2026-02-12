# Cursor Rules

This directory contains Cursor rule files (`.mdc`) that the IDE loads to apply
coding conventions.

## Files

- `go-project-architecture.mdc` - Go architecture rules, always apply
- `go-code-style.mdc` - Go code style summary, applies to `**/*.go`
- `go-testing.mdc` - Testing rules (table-driven, deterministic, cleanup)
- `go-performance.mdc` - Performance rules (profile-first, bounded concurrency)
- `go-security.mdc` - Security rules (validation, authz, safe logging)
- `go-docs.mdc` - Documentation rules (godoc, examples, design/changelog sync)
- `go-code-quality.mdc` - Code quality practices (composition, explicit errors)
- `superpowers.mdc` - Superpowers development workflow (brainstorm → spec → TDD → review)

## Full Rule Sources

To be compatible with this repository and other projects that install the rules,
the `.mdc` files should resolve rule references from either of these locations
under the project root:

- `.ai-context/rules/`
- `ai_go/v1/rules/`

## Installation

From the project root, run:

```
sh cursor_rules.sh go
```

This downloads `.mdc` files into `.cursor/rules` and full rules into
`.ai-context/rules`.
