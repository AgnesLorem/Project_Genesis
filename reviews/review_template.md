# Review Template

## Purpose

Every completed Project Genesis task must be reviewed using this template.

This template is for task review, not task planning. Reviewers should focus on correctness, scope, documentation alignment, maintainability, performance, scalability, and AI hallucination risk.

## Task Name

- Task ID:
- Task Title:
- Related Files:
- Related Documents:

## Reviewer

- Reviewer Name:
- Reviewer Role:

## Review Date

- Date:

## Summary

Briefly summarize what was reviewed.

- Scope reviewed:
- Key outcome:
- Remaining risk:

## Requirements Met

List requirements that were satisfied.

- [ ] Requirement:
- [ ] Requirement:
- [ ] Requirement:

## Requirements Missing

List requirements that were missing, incomplete, or unclear.

- [ ] Missing requirement:
- [ ] Missing requirement:
- [ ] Missing requirement:

## Code Quality

Use this section only when code was included in the task.

- [ ] Code is readable.
- [ ] Code is modular.
- [ ] Code follows repository naming standards.
- [ ] Code avoids unrelated changes.
- [ ] Code avoids hardcoded gameplay values.
- [ ] Code preserves server authority.
- [ ] Code separates gameplay logic from UI.
- [ ] Code handles invalid input safely.
- [ ] Code avoids unnecessary complexity.
- Notes:

## Documentation Quality

- [ ] Relevant documentation was read.
- [ ] Relevant documentation was updated.
- [ ] Documentation matches the completed work.
- [ ] New decisions are recorded in `docs/DECISIONS.md` if needed.
- [ ] Known unresolved issues are recorded in `docs/KNOWN_ISSUES.md` if needed.
- [ ] No undocumented mechanic was added.
- [ ] No future system was implied as MVP scope without approval.
- Notes:

## Gameplay Quality

Use this section for gameplay, combat, economy, progression, creature, gene, evolution, collection, boss, quest, or tower-related work.

- [ ] Work aligns with `docs/GDD_MASTER.md`.
- [ ] Work aligns with relevant domain documents.
- [ ] Work supports MVP scope.
- [ ] Work avoids feature creep.
- [ ] Work is data-driven.
- [ ] Work avoids fake or unapproved balance values.
- [ ] Work avoids unapproved mechanics.
- Notes:

## Performance

- [ ] No obvious avoidable expensive operations were introduced.
- [ ] No uncontrolled loops, tasks, or event connections were introduced.
- [ ] No unnecessary replication was introduced.
- [ ] No avoidable high-frequency work was introduced.
- [ ] Performance risk is acceptable for MVP.
- Notes:

## Scalability

- [ ] Structure can support additional approved content.
- [ ] Data model can support documented future expansion without hardcoding.
- [ ] System boundaries remain clear.
- [ ] Work avoids premature framework complexity.
- [ ] Work avoids monolithic ownership.
- Notes:

## AI Hallucination Check

Review whether the task introduced anything not supported by project documentation.

- [ ] No undocumented features were added.
- [ ] No undocumented mechanics were added.
- [ ] No undocumented currencies, rewards, stats, formulas, quests, towers, events, or UI screens were added.
- [ ] No reserved system was promoted into MVP scope without approval.
- [ ] No chat-only decision was treated as durable authority.
- [ ] All assumptions are documented.
- Notes:

## Issues Found

List issues found during review.

| ID | Severity | Issue | File or Document | Required Action |
|---|---|---|---|---|
| REVIEW-001 | TBD | TBD | TBD | TBD |
| REVIEW-002 | TBD | TBD | TBD | TBD |

Severity options:

- Blocking
- Major
- Minor
- Suggestion

## Recommended Changes

List recommended changes before approval.

- [ ] Change:
- [ ] Change:
- [ ] Change:

## Approved

Use this section if the task is approved.

- [ ] Approved without changes.
- [ ] Approved with non-blocking follow-up.
- Approval Notes:

Approved By:

Date:

## Rejected

Use this section if the task is rejected or blocked.

- [ ] Rejected due to scope conflict.
- [ ] Rejected due to undocumented mechanics.
- [ ] Rejected due to missing documentation.
- [ ] Rejected due to architecture risk.
- [ ] Rejected due to data or save risk.
- [ ] Rejected due to gameplay or balance risk.
- [ ] Blocked pending design decision.
- Rejection Notes:

Rejected By:

Date:
