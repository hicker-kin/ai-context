---
description: Go project architecture rules (Clean Architecture)
---

# Go Project Architecture

Follow the full rules in:

- `@ai_go/v1/rules/project_architecture.md`

## When initializing a new project

- Use Cobra-CLI to scaffold; see **Project Initialization (Cobra)** in @ai_go/v1/rules/project_architecture.md for `cobra-cli init` (author, license, pkg-name) and `cobra-cli add <cmd>`.

## Key MUSTs

- Keep dependencies inward; inner layers MUST NOT import outer layers (exception: inner may use an outer package only if that outer package does not depend on any other internal package, e.g. infra as a leaf used by service).
- `internal/dao`, `internal/storage`, and `internal/domain` only used by `internal/service`; handlers must not call dao/storage/domain/infra directly.
- Forbid cyclic dependencies between packages.
- Define interfaces in the consuming layer; inject dependencies explicitly.
- Keep domain models independent of transport/persistence.
- Separate handlers, usecases/services, domain, and infra.
- Validate external input at the boundary and map to domain types.
- Check `docs/design` and update or add design documentation when service logic changed
