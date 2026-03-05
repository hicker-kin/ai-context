# bunx install init

本文件位于 `.cursor/skills/reame.md`：

```
<project-root>/
├── skills/                              ← 真实目录（source of truth）
│   ├── frontend-architecture/
│   ├── go-jwt/
│   ├── go-logging/
│   └── rst_go_base_guide/
└── .cursor/skills/                      ← 本文件所在目录
    ├── reame.md                         (本文件)
    ├── frontend-architecture  → ../../skills/frontend-architecture
    ├── go-jwt                 → ../../skills/go-jwt
    ├── go-logging             → ../../skills/go-logging
    └── rst_go_base_guide      → ../../skills/rst_go_base_guide
```

在项目根目录执行，先确保 `.cursor/skills/` 存在，再建立指向 `skills/` 的软链接：

```bash
mkdir -p .cursor/skills
ln -s ../../skills/frontend-architecture .cursor/skills/frontend-architecture
ln -s ../../skills/go-jwt                 .cursor/skills/go-jwt
ln -s ../../skills/go-logging             .cursor/skills/go-logging
ln -s ../../skills/rst_go_base_guide      .cursor/skills/rst_go_base_guide
```