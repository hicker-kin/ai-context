# Rule consistency fixes（2026-07-30）

## 变更说明

修正规则源文件及 Cursor、Claude 摘要中的一致性与正确性问题：

- 旧实现应删除并由版本控制保留历史，禁止仅为保留历史而注释旧代码。
- 120 字节限制仅约束包含 Go 代码 token 的物理行；纯注释行不受限制。
- 修正 nil slice 的 JSON 语义：nil 编码为 `null`，非 nil 空 slice 编码为 `[]`。
- 已有 API 优先保持现有 HTTP 响应契约；标准包装体仅用于新 API 或已批准迁移。
- 修正表驱动 gomock 示例，为每个并行子测试建立独立 mock 和完整期望。

## 冲突检查

检查 `core_principles_zh.md` 与 `code_style_zh.md`：

- 已消除“历史代码只能注释”与“删除过时注释、避免注释代码”的直接冲突。
- 未发现其他直接冲突。

## 同步范围

- `ai_go/v1/rules/` 中英文规则。
- `.cursor/rules/` 摘要。
- `.claude/rules/` 摘要。

## 验证

- 执行 `git diff --check`。
- 对中英文规则关键词和对应语义做一致性检查。
- 检查修改后的 Go 示例代码行长度。
