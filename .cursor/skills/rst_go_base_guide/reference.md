# Rule file reference

One-line summaries of each rule source used by rst_go_base_guide. Paths are relative to **project root** or, if not found there, to the **user directory** (`~/.cursor/skills` or `~/.claude/rules`). If a file is not found after both lookups, report the failure to the user; do not guess.

| File | Summary |
|------|---------|
| `ai_go/v1/rules/project_architecture.md` | Project structure, directory layout, layering and dependency rules, API design, observability, health checks, config, testing, security, Go version/module, project init (Cobra), technology stack, deployment. |
| `ai_go/v1/rules/code_style.md` | Go formatting, naming, file layout, request/response DTO tags, functions and methods, interfaces, slices and nil, errors, control flow, comments, context and concurrency, testing style, logging, summary do's and don'ts. |
| `.cursor/rules/go-project-architecture.mdc` | Short architecture MUSTs and “when initializing a new project”; points to full project_architecture.md. |
| `.cursor/rules/go-code-style.mdc` | Short code style MUSTs; points to full code_style.md. |

When in doubt, read the full file under `ai_go/v1/rules/` for the complete rule.
