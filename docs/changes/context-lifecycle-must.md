# Context lifecycle Must（2026-07-22）

## 变更说明

在 `ai_go/v1/rules/code_style.md` / `code_style_zh.md` 的 **Context and Concurrency** /
**Context 与并发** 章节加强生命周期相关 Must：

- 编写方法/函数时必须先考虑是否涉及可取消或后台生命周期。
- 若可能涉及，第一个参数必须是 `ctx context.Context`（接收者之后）。
- 任务须随进程/请求退出而结束时，必须传递可被所有者取消的父上下文；禁止用全新的
  `context.Background()` / `context.TODO()` 启动此类工作，以免 goroutine 成为僵尸、阻塞退出。
- `Background` / `TODO` 仅允许出现在有意的生命周期根（`main`、测试、带独立关闭钩子的独立任务）；子工作仍须使用派生的可取消上下文。

同步更新摘要：

- `.cursor/rules/go-code-style.mdc`
- `.claude/rules/go-code-style.md`
