# install_rules.sh：IDE 检测与安装路径（2026-04-01）

## 变更说明

- **克隆/更新缓存仓库**：逻辑不变（`~/.github/ai-context`，`git pull` 与 `--update` 行为不变）。
- **`.ai-context/rules/`**：仍复制 `ai_<语言>/v1/rules/*.md` 的完整规则，作为项目内权威副本。
- **IDE 分流**（在项目根目录执行时根据目录检测）：
  - 存在 **`.claude`** → 仅处理 Claude Code：复制仓库内 `.claude/rules/*.md` 至项目；若不存在 `.claude/CLAUDE.md` 则生成，简要规则指向 `@.claude/rules/`，完整文档指向 `@.ai-context/rules/`。
  - 否则存在 **`.cursor`** → 仅处理 Cursor：复制仓库内 `.cursor/rules/*.mdc`（及 `README.md` 若存在）至 `.cursor/rules/`；完整内容仍以 `.ai-context/rules/` 为准。
  - 否则存在 **`.joycode`** 或 **均未检测到** → 按 JoyCode 处理：不复制完整 md 到 `.joycode/rules/`，仅在缺少 `.joycode/JOYCODE.md` 时生成，条目全部使用 `@.ai-context/rules/`；未检测到 IDE 目录时 **优先 JoyCode**（会 `mkdir -p .joycode`）。
- **检测优先级**：`.claude` > `.cursor` > `.joycode`；三者都没有时视为 JoyCode。

## 修复：`ide: unbound variable`

在 `set -u` 下，若使用 `local ide` 后单独一行再 `ide=$(...)`，`ide` 在赋值前处于未设置，展开 `$ide` 会报错。已改为单行 `local ide_target="$(detect_ide || echo joycode)"`，并统一使用 `${ide_target}` 引用。

## 与旧行为的差异

- 以前会同时填充 `.ai-context/rules` 与 `.joycode/rules`（重复拷贝完整 md）。现在 JoyCode 侧仅保留入口文档，引用 `.ai-context/rules/`。
- 根据项目已有目录选择单一 IDE 目标，避免多 IDE 重复拷贝。
