# 禁止魔法值 Must（2026-10-12）

## 变更说明

在 `ai_go/v1/rules/code_style.md` / `code_style_zh.md` 增加 **Magic Values** /
**魔法值** 强制约束，替换命名章节里「不变量用 const、枚举用 iota」的弱表述：

- **MUST NOT** 在逻辑中使用魔法值：未命名、且承载状态、编码、限额、阈值、超时、
  比例、键、路径或角色含义的数字或字符串字面量。
- **MUST** 用 `const` 命名；枚举 **MUST** 使用 `iota`。字面量只出现在常量声明中；
  标准库已有名称（如 `http.StatusOK`、`time.Second`）时直接使用。
- 下列情况不是魔法值，可以内联：`0` / `1` / `-1`（零值、计数、下标、切片边界）、
  `""`、布尔值、格式化字符串、日志或错误文案、`_test.go` 夹具与期望值。

同步更新摘要与引导：

- `.cursor/rules/go-code-style.mdc`
- `.claude/rules/go-code-style.md`
- `skills/rst_go_base_guide/SKILL.md`
- `skills/rst_go_base_guide/reference.md`

## 领域取值

同一天在 **Magic Values** / **魔法值** 之后增加 **Domain Values** / **领域取值**：

- 基本类型的合法内容若是一组固定业务术语（模式、引擎、拓扑、角色、状态码），
  **MUST NOT** 声明成看不出合法集合的裸 `string` / `int`。自由文本不受本条约束。
- **MUST** 用两种写法之一让取值在声明处可见。优先定义类型
  （`type Engine string`）并为每个已知值声明常量；表示「无法确认」的值必须单独
  成常量并注释。纯别名 `type Engine = string` 不合格。
- 仍用基本类型时，注释必须穷尽已知字面量，例如
  `"vllm" | "sglang" | ""（无法确认）`。只有一个已知值时写出那一个即可。
- 调用处仍必须使用常量名。穷尽注释不豁免「魔法值」。
