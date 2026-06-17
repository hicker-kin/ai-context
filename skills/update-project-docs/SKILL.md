---
name: update-project-docs
description: Use when project changes require documentation updates, including new features, major behavior changes, requirements documents, technical documents, architecture documents, design records, changelogs, README updates, API changes, configuration changes, migration notes, or release-facing summaries.
---

# Update Project Docs

## Overview

Maintain project documentation after requirements, implementation, architecture, API, configuration, or release-facing changes. Prefer precise incremental updates over rewriting whole documents.

This skill treats `README.md` as the project entry point and `docs/` as the home for deeper project documents.

## Documentation Structure

Use this structure when the project does not already define a stronger convention:

```text
docs/
  prd/
  tech/
  architecture/
  design/
  changelog/
README.md
```

Create directories only when they are needed for the current change.

## Document Types

Use `docs/prd/` for requirements documents:
- Business or product background
- User scenarios
- Goals and non-goals
- Functional scope
- Acceptance criteria

Use `docs/tech/` for technical documents:
- APIs, request/response shapes, and integration contracts
- Configuration, environment variables, and feature flags
- Data structures, storage details, and schemas
- Implementation notes that future developers need
- Debugging, testing, or operational details tied to implementation

Use `docs/architecture/` for current architecture:
- System structure as it exists now
- Module boundaries and responsibilities
- Data flow and control flow
- External dependencies and deployment shape
- Cross-system contracts and major runtime relationships

Use `docs/design/` for design records:
- Background and problem statement for a change
- Plans, proposals, and implementation strategy
- Alternatives considered
- Tradeoffs and decisions
- Risks, constraints, and rollout considerations

Use `docs/changelog/` for change summaries:
- New behavior
- Changed behavior
- Fixed behavior
- Compatibility impact
- Migration steps
- Verification notes

## Workflow

1. Inspect the project root for `README.md`, `docs/`, and any existing documentation conventions.
2. Classify the change before editing:
   - Requirement or product behavior: `docs/prd/`
   - Implementation, API, config, data, or debugging details: `docs/tech/`
   - Current system structure or module relationships: `docs/architecture/`
   - Planning, background, alternatives, tradeoffs, or decisions: `docs/design/`
   - Release-facing or handoff summary: `docs/changelog/`
   - Project entrypoint, setup, major capability, or public usage change: also check `README.md`
3. Prefer updating an existing relevant document. Create a new dated document only when no suitable document exists.
4. Preserve the language, heading style, naming style, and level of detail used by existing docs.
5. Keep each document focused on its purpose. Do not merge PRD, technical detail, architecture state, design reasoning, and changelog content into one document unless the project already has that convention.
6. Update links between documents when a new doc becomes important for navigation.
7. After editing, summarize what changed, why each document was touched, which likely documents were intentionally left unchanged, and what verification was performed.

## README Policy

Update `README.md` when a change affects:
- Project purpose or positioning
- Main capabilities
- Setup, run, test, deployment, or configuration steps
- Public API or primary usage flow
- Important compatibility or migration notes
- Links to important new documentation

Do not update `README.md` for small internal refactors, isolated bug fixes, or implementation-only changes unless they affect user-visible behavior or developer onboarding.

## Creation Policy

When creating a new Markdown document, use lowercase kebab-case with a date prefix:

```text
docs/prd/YYYY-MM-DD-feature-name.md
docs/tech/YYYY-MM-DD-topic.md
docs/architecture/YYYY-MM-DD-topic.md
docs/design/YYYY-MM-DD-topic.md
docs/changelog/YYYY-MM-DD-change-summary.md
```

Use the current local date. If the user provides a specific release date or milestone date, use that date instead.

## Templates

For new PRD documents, start with:

```markdown
# <Feature Or Requirement Name>

## Background

## Goals

## Non-Goals

## User Scenarios

## Requirements

## Acceptance Criteria

## Open Questions
```

For new technical documents, start with:

```markdown
# <Technical Topic>

## Context

## Interfaces

## Data And Configuration

## Implementation Notes

## Testing And Debugging

## Risks
```

For new architecture documents, start with:

```markdown
# <Architecture Topic>

## Overview

## Components

## Data Flow

## Dependencies

## Operational Shape

## Constraints
```

For new design documents, start with:

```markdown
# <Design Topic>

## Background

## Plan

## Alternatives Considered

## Decision

## Tradeoffs

## Risks

## Rollout
```

For new changelog documents, start with:

```markdown
# <Change Summary>

## Added

## Changed

## Fixed

## Compatibility

## Migration

## Verification
```

Remove empty sections that do not apply, unless the project convention keeps them.

## Common Mistakes

- Updating only changelog when the change also affects setup, API usage, or README navigation.
- Putting design reasoning in `docs/architecture/`; architecture should describe the current system, while design should explain plans and decisions.
- Rewriting whole documents when a focused section update is enough.
- Creating new documents without checking whether an existing doc should be updated.
- Burying user-facing breaking changes inside technical notes instead of surfacing them in changelog and README when appropriate.
