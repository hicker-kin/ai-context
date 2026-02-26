# Rule file reference

One-line summaries of each rule source used by rst_go_base_guide. Paths are relative to **project root** or, if not found there, to the **user directory** (`~/.cursor/skills` or `~/.claude/rules`). If a file is not found after both lookups, report the failure to the user; do not guess.

| File | Summary |
|------|---------|
| `ai_go/v1/rules/project_architecture.md` | Project structure, directory layout, layering and dependency rules, API design, observability, health checks, config, testing, security, Go version/module, project init (Cobra), technology stack, deployment. |
| `ai_go/v1/rules/project_architecture_zh.md` | 同上（中文版） |
| `.ai-context/rules/project_architecture_zh.md` | 同上（中文版，三方项目） |
| `ai_go/v1/rules/code_style.md` | Go formatting, naming, file layout, request/response DTO tags, functions and methods, interfaces, slices and nil, errors, control flow, comments, context and concurrency, testing style, logging, summary do's and don'ts. |
| `ai_go/v1/rules/code_style_zh.md` | 同上（中文版） |
| `.ai-context/rules/code_style_zh.md` | 同上（中文版，三方项目） |
| `ai_go/v1/rules/code_quality.md` | Composition, explicit errors, cleanup. |
| `ai_go/v1/rules/code_quality_zh.md` | 同上（中文版） |
| `.ai-context/rules/code_quality_zh.md` | 同上（中文版，三方项目） |
| `ai_go/v1/rules/performance.md` | Profile-first, bounded concurrency, N+1 avoidance. |
| `ai_go/v1/rules/performance_zh.md` | 同上（中文版） |
| `.ai-context/rules/performance_zh.md` | 同上（中文版，三方项目） |
| `ai_go/v1/rules/testing.md` | Table-driven tests, deterministic, cleanup. |
| `ai_go/v1/rules/testing_zh.md` | 同上（中文版） |
| `.ai-context/rules/testing_zh.md` | 同上（中文版，三方项目） |
| `ai_go/v1/rules/security.md` | Input validation, authz, safe logging. |
| `ai_go/v1/rules/security_zh.md` | 同上（中文版） |
| `.ai-context/rules/security_zh.md` | 同上（中文版，三方项目） |
| `ai_go/v1/rules/documentation.md` | Godoc, examples, design/changelog sync. |
| `ai_go/v1/rules/documentation_zh.md` | 同上（中文版） |
| `.ai-context/rules/documentation_zh.md` | 同上（中文版，三方项目） |
| `.cursor/rules/go-project-architecture.mdc` | Short architecture MUSTs and “when initializing a new project”; points to full project_architecture.md. |
| `.cursor/rules/go-code-style.mdc` | Short code style MUSTs; points to full code_style.md. |

When in doubt, read the full file under `ai_go/v1/rules/` or `.ai-context/rules/` for the complete rule. Use `*_zh.md` for Chinese version. In third-party projects, rules are under `.ai-context/rules/`.
