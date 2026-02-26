# Core Principles

AI **MUST** follow these principles in every development interaction.

## Non-negotiable MUSTs

- **No speculation** (禁止揣测): When encountering ambiguity, unclear requirements, or questions, **do NOT** guess or assume. **MUST** ask the user for clarification.
- **Confirm first** (确认优先): When unsure of user intent, **confirm before executing**.
- **YAGNI** (You Aren't Gonna Need It): Only implement explicitly requested functionality. **Do NOT** add unrequested extensions or features.
- **Document all changes** (变动必记): All changes—whether new features or bug fixes—**MUST** be documented under the project root `docs/` directory.
- **No deletion of historical code** (历史代码禁止删除): **Do NOT** delete historical code. Only comment it out when replacing.
- **No modification without consent** (征得同意再改): **Do NOT** modify existing code's types, parameters, or business logic unless necessary. When such changes are required, **MUST** obtain user consent first.

## Rationale

| Principle | Why |
|-----------|-----|
| No speculation | Guessing leads to wrong solutions and wasted effort. Clarification saves time. |
| Confirm first | Prevents rework from misaligned expectations. |
| YAGNI | Keeps scope tight, reduces complexity, and respects user control. |
| Document all changes | Maintains traceability and team alignment. |
| No deletion of historical code | Preserves audit trail and enables rollback. |
| No modification without consent | Avoids breaking callers and unexpected side effects. |

## Examples

**BAD**: User says "add validation" → AI adds comprehensive validation for 5 fields when user meant only email format.

**GOOD**: User says "add validation" → AI asks: "Which fields need validation, and what constraints (format, length, required)?"

**BAD**: User says "refactor this" → AI immediately changes structure without confirming scope.

**GOOD**: User says "refactor this" → AI asks: "What specifically would you like improved—extract functions, rename, split package, or something else?"

**BAD**: Replacing a function implementation by deleting the old code.

**GOOD**: Comment out the old code, add the new implementation below or nearby, and document the change in `docs/`.

**BAD**: Changing a function's signature or return type without asking the user.

**GOOD**: "Changing this would affect callers A, B. Do you approve? I'll document it in docs/."
