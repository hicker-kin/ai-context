# go-import skill（2026-04-01）

## 变更说明

- 新增 `skills/go-import/SKILL.md`，将 `ai_go/v1/rules/code_style.md` 中 `imports` 排序规则沉淀为可复用 skill。
- 新增 `skills/go-import/examples.md`，提供 BAD/GOOD 对照示例，便于快速检查与教学。
- 补充 `skills/go-import/SKILL.md`：明确“本地包”的判定必须以 `go.mod` 的 `module` 路径为**精确前缀**；并新增硬性限制：使用该技能时，本地包必须放在最后一组（第 4 组）。
- 更新 `cursor_skills.sh`：将 `go-import` 加入 Go 技能安装列表（`GO_SKILLS`）。
- 更新 `.cursor/skills/reame.md`：补充 `go-import` 目录结构、软链接示例命令。
- 在 `.cursor/skills/` 下新增软链接 `go-import -> ../../skills/go-import`，使 Cursor 可直接加载该技能。
- 同步到 Claude 侧：新增 `.claude/skills/go-import/`，包含 `SKILL.md` 与 `examples.md`。

## 规则摘要（来源）

基于 `ai_go/v1/rules/code_style.md` 的 `imports` 规则：

1. 标准库
2. 第三方依赖
3. 二方库（同组织共享库/SDK）
4. 本地模块（当前 `go.mod` module）

各组之间使用空行分隔，推荐配合 `goimports` 与 `gofmt -s`。
