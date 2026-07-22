# Function size / structure Must（2026-07-22）

## 变更说明

在 `ai_go/v1/rules/code_style.md` / `code_style_zh.md` 增加函数体积、结构与复用硬约束：

- 单行 **MUST** ≤ 120 字节（UTF-8 byte length；由原 SHOULD ≤ 120 字符升级）。
- 单个函数/方法 **MUST** ≤ 150 行（签名到结束 `}`）。
- 每个重要节点 **MUST** 有注释（非显然分支、错误取舍、状态迁移、I/O 边界、守卫）。
- 职责超过 3 个时 **MUST** 使用 `// step1: ...` ~ `// stepN: ...`（英文）。
- **MUST** 优先抽可复用 helper，避免流水账；与 Comments「why not what」协调：step 标记为强制例外。

同步更新摘要：

- `.cursor/rules/go-code-style.mdc`
- `.claude/rules/go-code-style.md`
