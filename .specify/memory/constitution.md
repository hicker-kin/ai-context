# Project Constitution

This document defines the governing principles and development guidelines for this repository. All specifications, plans, and implementations MUST align with these principles. Detailed rules and contracts live in the referenced documentation; this constitution states the *what* and *why*, not the *how*.

---

## 1. Architecture and Layering

- **Clean Architecture** is mandatory. Boundaries between handlers, services, domain, and infrastructure MUST be explicit and respected.
- **Dependencies point inward.** Inner layers MUST NOT import outer layers, except when an outer package is a leaf (e.g. infra used by service with no other internal deps).
- **Handlers** (HTTP/gRPC) call **service** only. They MUST NOT call dao, storage, domain, or infra directly.
- **Domain models** are independent of transport and persistence. No framework or I/O types in domain.
- **Interfaces** are defined in the consuming layer; dependencies are injected explicitly. Prefer small, purpose-specific interfaces and composition over inheritance.
- **Cyclic dependencies** between packages are forbidden.

---

## 2. Code Quality and Style

- All code MUST follow the **Formatting and Naming** rules defined in the project's code style (see Documentation References).
- External input MUST be validated at the boundary (handlers); map to domain types before use.
- Modules and packages MUST have clear I/O contracts. Implementation details belong in feature specs and plans, not in this constitution.

---

## 3. Testing and Observability

- Business logic MUST be testable via interfaces and dependency injection.
- Test coverage and testing strategy are defined per feature in specs and plans.
- Observability (logging, metrics, tracing) should be considered at the boundary and documented in design/specs where relevant.

---

## 4. Documentation and Design

- For every **business logic or behavior change**, `docs/design` MUST be checked and updated or extended as needed.
- PRD, design docs, conventions, and API notes MUST live under **docs/design** (or project-equivalent). Changelog and SDD-related docs under **docs/changelog**.
- Specifications and implementation plans reference this constitution; detailed contracts, schemas, and validation rules belong in feature specs (`/speckit.specify`, `/speckit.plan`) and in `contracts/` or equivalent under each feature.

---

## 5. Technical Decisions and Governance

- Technical choices (tech stack, frameworks, libraries) are made in **plans** and **specs**, guided by these principles.
- When in doubt, prefer: clarity over cleverness, explicitness over convention, and auditability of decisions in docs/design and specs.
- This constitution is updated only during initialization or intentional governance changes; feature work MUST NOT modify this file unless the change is purely constitutional.

---

## Documentation References

| Purpose | Location |
|--------|----------|
| Project structure, layering, API design, Cobra init | `ai_go/v1/rules/project_architecture.md` |
| Go formatting, naming, file layout | `ai_go/v1/rules/code_style.md` |
| Cursor/IDE rules (summary) | `.cursor/rules/` (e.g. `go-project-architecture.mdc`, `go-code-style.mdc`) |
| Design docs, PRD, API notes | `docs/design/` |
| Changelog, SDD-related docs | `docs/changelog/` |
| Feature specs, plans, tasks | `.specify/specs/<feature>/` (when using Spec-kit) |

---

*This constitution was created for spec-driven development. Use `/speckit.specify` for requirements, `/speckit.plan` for technical plans, and keep implementation details in those artifacts and in the referenced docs.*
