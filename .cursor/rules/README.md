# Cursor Rules

This directory contains Cursor rule files (`.mdc`) that the IDE loads to apply
coding conventions.

## Files
- `go-code-style.mdc` - Go code style summary, applies to `**/*.go`
- `go-project-architecture.mdc` - Go architecture rules, always apply

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
