# go-import skill（2026-04-01）

## 变更说明

- 新增 `skills/go-import/SKILL.md`，将 `ai_go/v1/rules/code_style.md` 中 `imports` 排序规则沉淀为可复用 skill。
- 新增 `skills/go-import/examples.md`，提供 BAD/GOOD 对照示例，便于快速检查与教学。
- 早期版本曾采用 4 组文档表述：标准库、第三方、二方库、本地模块；该表述用于沉淀来源规则，但并不总能和通用 formatter 默认输出保持一致。
- 更新 `cursor_skills.sh`：将 `go-import` 加入 Go 技能安装列表（`GO_SKILLS`）。
- 更新 `.cursor/skills/reame.md`：补充 `go-import` 目录结构、软链接示例命令。
- 在 `.cursor/skills/` 下新增软链接 `go-import -> ../../skills/go-import`，使 Cursor 可直接加载该技能。
- 同步到 Claude 侧：新增 `.claude/skills/go-import/`，包含 `SKILL.md` 与 `examples.md`。
- 2026-05-09 调整为工业化默认策略：优先遵循仓库现有自动化；无仓库约定时，推荐 `goimports` + `gci` 的 3 组布局（标准库 / 模块外依赖 / 当前模块）；仅在仓库明确要求时拆分二方库。
- 2026-05-09 补充 `gci` 缺失时的处理：优先通过 `go install github.com/daixiang0/gci@latest` 安装；若安装条件不满足，则接受 `goimports -local` 的结果作为降级路径，而不是手工发明新的全仓分组规则。
- 2026-05-09 补充 module root 与 multi-module 约束：无仓库自动化时从目标 `go.mod` 所在目录执行 fallback 命令；多模块仓库逐个 module 执行；安装 `gci` 需满足环境和用户权限。

## 规则摘要（来源）

来源规则曾基于 `ai_go/v1/rules/code_style.md` 的 4 组 `imports` 表达：

1. 标准库
2. 第三方依赖
3. 二方库（同组织共享库/SDK）
4. 本地模块（当前 `go.mod` module）

当前 skill 的默认落地策略做了收敛：

1. 优先仓库自动化
2. 其次使用 `goimports`
3. 若可用则追加 `gci` 形成 3 组布局
4. 只有仓库已有明确配置时才保留二方库单独分组
