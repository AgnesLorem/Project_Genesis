# Project Genesis Development Workflow

## Purpose

This document defines the complete development lifecycle for Project Genesis.

It is mandatory for all AI assistants, human developers, reviewers, and project owners working in the repository.

The workflow exists to ensure every idea becomes production work only after it has been discussed, approved, documented, scoped, implemented, reviewed, tested, balanced, merged, and released through a consistent process.

Project Genesis is currently limited to MVP scope. No phase in this workflow authorizes feature creep, undocumented mechanics, or implementation work outside the approved MVP.

## Status

- Document Status: Active
- Scope: MVP development workflow
- Applies To: All contributors
- Owner: Project Director
- Last Updated: 2026-06-28

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Workflow Overview](#workflow-overview)
- [Workflow Principles](#workflow-principles)
- [Definition of Ready](#definition-of-ready)
- [Definition of Done](#definition-of-done)
- [Phase 1: Idea](#phase-1-idea)
- [Phase 2: Discussion](#phase-2-discussion)
- [Phase 3: Design Decision](#phase-3-design-decision)
- [Phase 4: Documentation](#phase-4-documentation)
- [Phase 5: Task Creation](#phase-5-task-creation)
- [Phase 6: Implementation](#phase-6-implementation)
- [Phase 7: Internal Review](#phase-7-internal-review)
- [Phase 8: Human Playtest](#phase-8-human-playtest)
- [Phase 9: Balance Pass](#phase-9-balance-pass)
- [Phase 10: Merge](#phase-10-merge)
- [Phase 11: Release](#phase-11-release)
- [Scope Control](#scope-control)
- [Iteration Rules](#iteration-rules)
- [Review Gates](#review-gates)
- [Role Responsibilities](#role-responsibilities)
- [Workflow Checklists](#workflow-checklists)
- [Professional Conclusion](#professional-conclusion)

## Workflow Overview

Project Genesis follows this production lifecycle:

```text
Idea
  ↓
Discussion
  ↓
Design Decision
  ↓
Documentation
  ↓
Task Creation
  ↓
Implementation
  ↓
Internal Review
  ↓
Human Playtest
  ↓
Balance Pass
  ↓
Merge
  ↓
Release
```

No implementation may begin until the work is ready.

No task may be merged until it satisfies the Definition of Done.

No release may be published until the merged work has been validated against the approved MVP scope.

## Workflow Principles

The workflow is built on the following principles:

- Documentation is the source of truth.
- MVP scope is protected at every phase.
- Every implementation must trace back to an approved decision.
- Every approved decision must be recorded.
- Every task must be small enough to review.
- Every feature must support progression, usability, stability, or production readiness.
- Gameplay values must be data-driven where applicable.
- Server authority must be protected where applicable.
- AI assistants must not invent mechanics.
- Human review is required before release.
- Work is not complete until it is validated.

## Definition of Ready

Definition of Ready determines whether a task is prepared for implementation.

A task that is not ready must not enter implementation.

### Ready Checklist

- [ ] The work is within MVP scope.
- [ ] The work has a clear purpose.
- [ ] The work has a documented source of truth.
- [ ] The work has an approved design decision when required.
- [ ] The work has clear acceptance criteria.
- [ ] The work has known dependencies listed.
- [ ] The work has an owner or assigned contributor.
- [ ] The expected output is clear.
- [ ] Required documents are identified.
- [ ] Required data schemas are identified where applicable.
- [ ] Required UI behavior is identified where applicable.
- [ ] Required server authority rules are identified where applicable.
- [ ] Required testing approach is identified.
- [ ] Review requirements are identified.
- [ ] Open questions are resolved or explicitly logged.
- [ ] The task can be completed without inventing mechanics.

### Not Ready Conditions

A task is not ready if:

- It requires an undocumented mechanic.
- It depends on an unresolved design question.
- It conflicts with `docs/GDD_MASTER.md`.
- It conflicts with `docs/DECISIONS.md`.
- It exceeds MVP scope.
- It has vague acceptance criteria.
- It requires unrelated refactoring.
- It requires gameplay values that are not documented or intentionally left as placeholders.
- It cannot be reviewed in a focused way.

## Definition of Done

Definition of Done determines whether a task can officially be considered complete.

The authoritative completion standard is defined in `docs/DEFINITION_OF_DONE.md`.

### Done Checklist Summary

- [ ] The task matches the approved scope.
- [ ] The task follows the relevant source-of-truth documents.
- [ ] The task does not introduce undocumented mechanics.
- [ ] The task does not modify unrelated files.
- [ ] The task is implemented or documented to the required quality level.
- [ ] The task is tested or validated.
- [ ] Documentation is updated.
- [ ] Review requirements are satisfied.
- [ ] Blocking issues are resolved.
- [ ] Completion evidence is recorded.

If any required item is incomplete, the task is not done.

## Phase 1: Idea

### Purpose

The Idea phase captures a possible improvement, task, content need, design question, technical need, or production concern.

An idea is not approval.

An idea is only the starting point for discussion.

### Who Is Responsible

- Human project owner.
- Project Director.
- AI assistants.
- Reviewers.
- Designers.
- Developers.

Any contributor may raise an idea.

### Required Documents

- `docs/GDD_MASTER.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/MVP_CHECKLIST.md`
- `docs/KNOWN_ISSUES.md`

### Expected Outputs

- Clear idea statement.
- Reason the idea is being raised.
- Affected systems.
- Initial MVP relevance assessment.
- Initial risk notes.
- Open questions, if any.

### Entry Criteria

- A contributor identifies a possible need or improvement.
- The idea can be described in plain language.
- The idea has a plausible connection to MVP goals.

### Exit Criteria

- The idea is either moved to Discussion, rejected as out of scope, or logged as an unresolved issue.
- The idea has enough context for another contributor to understand it.

### Review Gate

The Project Director or responsible reviewer must confirm:

- The idea is worth discussing.
- The idea does not immediately violate MVP scope.
- The idea is not already answered by existing documentation.

### Scope Control

Ideas must not be implemented during this phase.

Ideas must not be treated as approved design.

Ideas that introduce new mechanics must be held until they pass through Design Decision.

### Iteration Rules

An idea may be revised, narrowed, combined with another idea, or rejected.

Rejected ideas should not be reintroduced unless new project context changes the evaluation.

## Phase 2: Discussion

### Purpose

The Discussion phase evaluates whether an idea should become an approved decision, a documented task, or a rejected proposal.

Discussion exists to clarify intent before documentation or implementation begins.

### Who Is Responsible

- Project Director.
- Human project owner.
- Relevant AI assistant.
- Reviewer.
- Domain owner when applicable.

### Required Documents

- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/BALANCE.md` when balance is affected.
- `docs/TECH_ARCHITECTURE.md` when architecture is affected.
- `docs/DATA_SCHEMA.md` when data is affected.
- `docs/COMBAT.md` when combat is affected.
- `docs/CONTENT_PIPELINE.md` when content workflow is affected.

### Expected Outputs

- Clarified problem statement.
- Proposed scope.
- Affected systems list.
- Risks and tradeoffs.
- Required decision type.
- Required documentation updates.
- Recommendation to accept, reject, revise, or defer.

### Entry Criteria

- An idea has passed the Idea phase.
- The relevant documents have been checked.
- The discussion has a clear topic.

### Exit Criteria

- The team understands the intended change.
- MVP relevance has been confirmed.
- Required decision ownership is clear.
- Open questions are resolved or recorded.
- The idea is ready for a Design Decision or is rejected.

### Review Gate

The reviewer must confirm:

- The discussion did not create implied approval.
- The proposed scope is specific.
- The proposed scope can be documented.
- The proposed scope can be tested.

### Scope Control

Discussion must not expand the idea beyond the MVP unless explicitly rejected from the active workflow.

When a discussion exposes a larger system need, the immediate task must be narrowed to the smallest MVP-compatible slice.

### Iteration Rules

Discussion may repeat until the proposal is clear.

If the same unresolved question blocks progress repeatedly, it must be logged in `docs/KNOWN_ISSUES.md`.

## Phase 3: Design Decision

### Purpose

The Design Decision phase converts an approved direction into a permanent decision record.

This phase prevents undocumented mechanics, architecture drift, and inconsistent AI implementation.

### Who Is Responsible

- Human project owner.
- Project Director.
- Design owner.
- Technical owner when architecture is affected.
- Reviewer.

### Required Documents

- `docs/DECISIONS.md`
- `docs/GDD_MASTER.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/KNOWN_ISSUES.md`

### Expected Outputs

- New or updated decision record.
- Accepted, Rejected, or Deprecated status.
- Clear reasoning.
- Affected systems.
- Impact statement.
- Date.

### Entry Criteria

- Discussion has produced a clear recommendation.
- The decision is needed before documentation or implementation.
- The decision has known affected systems.

### Exit Criteria

- The decision is recorded in `docs/DECISIONS.md`.
- The decision status is explicit.
- The decision does not conflict with existing accepted decisions.
- Related open questions are updated or closed.

### Review Gate

The Project Director must confirm:

- The decision is necessary.
- The decision is MVP-compatible.
- The decision is specific enough to guide work.
- The decision does not approve hidden scope expansion.

### Scope Control

A design decision must approve only the specific decision described.

It must not be used to imply approval for related systems, extra content, additional rewards, or unrelated architecture changes.

### Iteration Rules

If a decision changes, the old decision must not be deleted.

It must be marked Deprecated or Rejected, and the replacement decision must be recorded separately.

## Phase 4: Documentation

### Purpose

The Documentation phase updates the source of truth before implementation begins.

Project Genesis requires design and technical intent to be written before code, content, or production work is started.

### Who Is Responsible

- Documentation author.
- Project Director.
- Domain owner.
- Reviewer.

### Required Documents

The required documents depend on the task:

- `docs/GDD_MASTER.md` for core design.
- `docs/DECISIONS.md` for approved decisions.
- `docs/DATA_SCHEMA.md` for data structure.
- `docs/COMBAT.md` for combat behavior.
- `docs/BALANCE.md` for balance philosophy.
- `docs/TECH_ARCHITECTURE.md` for architecture.
- `docs/CONTENT_PIPELINE.md` for content workflows.
- `docs/STYLE_GUIDE.md` for formatting and naming.
- `docs/MVP_CHECKLIST.md` for task tracking.
- `docs/KNOWN_ISSUES.md` for unresolved questions.

### Expected Outputs

- Updated source-of-truth documentation.
- Clear section ownership.
- Updated placeholders where appropriate.
- Explicit unresolved questions where appropriate.
- No speculative mechanics presented as approved.

### Entry Criteria

- Required design decisions are recorded.
- Required discussion has completed.
- Documentation scope is known.
- The document owner is clear.

### Exit Criteria

- The documentation accurately reflects the approved decision or approved task.
- The documentation is internally consistent.
- The documentation avoids fake numbers.
- The documentation avoids unapproved mechanics.
- The documentation gives implementation enough guidance to proceed.

### Review Gate

The reviewer must confirm:

- Documentation matches the decision.
- Documentation does not exceed the decision.
- Documentation is clear enough for implementation.
- Documentation uses project terminology consistently.

### Scope Control

Documentation must not silently approve new mechanics.

If a writer discovers missing design, the missing design must become a Discussion or Known Issue item rather than being filled in through assumption.

### Iteration Rules

Documentation may be revised until it is specific enough for implementation.

Implementation must not begin while required documentation is contradictory or incomplete.

## Phase 5: Task Creation

### Purpose

The Task Creation phase converts approved documentation into actionable work.

Tasks must be specific, scoped, reviewable, and ready for implementation.

### Who Is Responsible

- Project Director.
- Producer or task owner.
- Relevant AI assistant.
- Reviewer.

### Required Documents

- `docs/MVP_CHECKLIST.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/STYLE_GUIDE.md`
- Relevant design or technical document.
- `reviews/review_template.md`

### Expected Outputs

- Task file or checklist entry.
- Acceptance criteria.
- Dependencies.
- Priority.
- Current status.
- Definition of Done notes.
- Testing checklist.
- Review checklist.

### Entry Criteria

- Documentation is approved.
- The task is within MVP scope.
- Required decisions are recorded.
- Open blockers are resolved or logged.

### Exit Criteria

- The task satisfies Definition of Ready.
- The task has clear acceptance criteria.
- The task has a known owner.
- The task has known dependencies.
- The task has a review path.

### Review Gate

The reviewer must confirm:

- The task is small enough to complete.
- The task is small enough to review.
- The task has no hidden design work.
- The task has no implied extra systems.

### Scope Control

Each task must describe one coherent unit of work.

Large tasks must be split before implementation.

Task scope may not expand during implementation unless the task returns to Discussion or Documentation.

### Iteration Rules

Tasks may be edited before implementation.

Once implementation begins, scope changes require review and documentation updates.

## Phase 6: Implementation

### Purpose

The Implementation phase produces the approved work exactly as documented.

Implementation must follow project architecture, naming standards, data-driven rules, and MVP scope.

### Who Is Responsible

- Assigned developer.
- Assigned AI assistant.
- Domain owner.

### Required Documents

- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/STYLE_GUIDE.md`
- `docs/TECH_ARCHITECTURE.md`
- Relevant domain documentation.
- Assigned task file or checklist item.

### Expected Outputs

- Implemented task.
- Updated documentation.
- Validation notes.
- Test results.
- Known limitations, if any.
- No unrelated file changes.

### Entry Criteria

- The task satisfies Definition of Ready.
- Required documents have been read.
- Acceptance criteria are clear.
- Dependencies are available.
- The task can be implemented without invention.

### Exit Criteria

- The task satisfies the requested scope.
- The task satisfies applicable programming, documentation, gameplay, performance, security, and testing requirements.
- The task has completion evidence.
- The task is ready for Internal Review.

### Review Gate

The implementer must self-check:

- Did the work match the task?
- Did the work stay within scope?
- Did the work avoid unrelated changes?
- Did the work avoid undocumented mechanics?
- Did the work update required documentation?
- Did the work pass relevant validation?

### Scope Control

Implementation must stop if the contributor discovers:

- Missing approval.
- Missing documentation.
- Contradictory documentation.
- Required design not defined.
- Scope larger than the task.
- Required architecture not defined.

The contributor must then return the issue to Discussion, Documentation, or Known Issues.

### Iteration Rules

Implementation may iterate within the approved task scope.

Implementation may not add extra systems because they appear convenient.

Implementation may not convert placeholders into mechanics without approval.

## Phase 7: Internal Review

### Purpose

The Internal Review phase verifies quality, scope, documentation, architecture, and consistency before human playtest.

Internal review is required for completed tasks.

### Who Is Responsible

- Reviewer Agent.
- Project Director.
- Human reviewer.
- Domain owner.

### Required Documents

- `reviews/review_template.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_PRINCIPLES.md`
- `agents/AGENTS.md`
- Relevant domain documentation.

### Expected Outputs

- Completed review record.
- Approved or rejected status.
- Issues found.
- Required changes.
- Documentation quality assessment.
- Scope assessment.
- AI hallucination check.

### Entry Criteria

- Implementation is complete according to the contributor.
- Documentation updates are included.
- Validation notes are available.
- The task has completion evidence.

### Exit Criteria

- Review is approved, or the task is returned for revision.
- Blocking issues are clearly identified.
- Non-blocking issues are documented.
- Required changes are assigned.

### Review Gate

The reviewer must check:

- Requirements met.
- Requirements missing.
- Code quality when code is involved.
- Documentation quality.
- Gameplay quality when gameplay is involved.
- Performance risk.
- Scalability risk.
- AI hallucination risk.
- Scope control.

### Scope Control

Review must reject:

- Undocumented mechanics.
- Unrelated changes.
- Unapproved scope expansion.
- Hardcoded gameplay values where data-driven values are required.
- Client authority over gameplay outcomes.
- Documentation that claims incomplete behavior is complete.

### Iteration Rules

If review rejects the task, it returns to Implementation or Documentation.

If review exposes missing design, it returns to Discussion or Design Decision.

Review comments must be resolved before merge.

## Phase 8: Human Playtest

### Purpose

The Human Playtest phase validates that the implemented work behaves correctly for a player.

Human playtest focuses on actual user flow, clarity, responsiveness, and production readiness.

### Who Is Responsible

- Human playtester.
- Project owner.
- Project Director.
- Assigned contributor for fixes.

### Required Documents

- Assigned task file or checklist item.
- `docs/GDD_MASTER.md`
- `docs/DEFINITION_OF_DONE.md`
- Relevant domain documentation.
- Review record.

### Expected Outputs

- Playtest notes.
- Observed issues.
- Reproduction steps for issues.
- Usability concerns.
- Progression concerns.
- Balance concerns.
- Approval or revision request.

### Entry Criteria

- Internal Review is approved.
- The work can be accessed through the intended flow.
- Required setup steps are documented.
- The playtester knows what to validate.

### Exit Criteria

- The primary player flow has been tested.
- Blocking usability issues are documented.
- Blocking functional issues are documented.
- Required fixes are assigned.
- The work is approved for Balance Pass or returned for revision.

### Review Gate

The playtester must confirm:

- The feature can be reached.
- The feature can be understood.
- The feature behaves as documented.
- The feature does not break normal MVP flow.
- The feature does not create obvious progression confusion.

### Scope Control

Playtest feedback must separate:

- Bugs.
- Usability issues.
- Documentation mismatches.
- Balance concerns.
- New ideas.

New ideas discovered during playtest must return to Idea or Discussion and must not be added to the current task without approval.

### Iteration Rules

Playtest may repeat after fixes.

Only issues tied to the approved task should be fixed inside the current task.

New ideas must be logged separately.

## Phase 9: Balance Pass

### Purpose

The Balance Pass phase checks whether gameplay, economy, progression, rewards, and difficulty remain consistent with the approved balance philosophy.

This phase does not invent new numeric values unless the task explicitly includes approved balancing work.

### Who Is Responsible

- Balance owner.
- Economy Agent when economy is affected.
- Gameplay Agent when combat or progression is affected.
- Project Director.
- Human reviewer.

### Required Documents

- `docs/BALANCE.md`
- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/COMBAT.md` when combat is affected.
- `docs/ECONOMY.md` when economy is affected.
- `docs/PROGRESSION.md` when progression is affected.
- Relevant task documentation.

### Expected Outputs

- Balance review notes.
- Confirmed variables.
- Unknown variables logged.
- Placeholder values confirmed as placeholders where applicable.
- Required adjustments, if approved.
- Recommendation to merge or revise.

### Entry Criteria

- Human Playtest is complete when applicable.
- The affected systems are known.
- Balance-relevant data or behavior is identifiable.
- The review can be performed without inventing mechanics.

### Exit Criteria

- Balance risks are identified.
- Blocking balance concerns are resolved or logged.
- Documentation matches the current balance intent.
- The task is approved for Merge or returned for revision.

### Review Gate

The balance reviewer must confirm:

- No fake numbers were introduced.
- No reward path was added without approval.
- No scaling rule was added without documentation.
- No power gate was introduced where only recommendation is approved.
- No economy behavior contradicts documented philosophy.
- No progression shortcut was introduced without approval.

### Scope Control

Balance Pass must not become a redesign phase.

If balance review reveals a design gap, the task returns to Discussion or Design Decision.

### Iteration Rules

Balance changes must be documented.

Balance changes must remain within the approved task.

Unknown values must remain placeholders until approved.

## Phase 10: Merge

### Purpose

The Merge phase officially accepts completed work into the stable project state.

Merge is not allowed until the work satisfies the Definition of Done and all required review gates.

### Who Is Responsible

- Project Director.
- Human project owner.
- Reviewer.
- Maintainer.

### Required Documents

- `docs/DEFINITION_OF_DONE.md`
- `reviews/review_template.md`
- Relevant task file or checklist entry.
- `docs/MVP_CHECKLIST.md`
- `docs/CHANGELOG.md` when applicable.

### Expected Outputs

- Approved merge.
- Updated task status.
- Updated checklist status.
- Updated changelog entry when applicable.
- Final completion notes.

### Entry Criteria

- Implementation is complete.
- Internal Review is approved.
- Human Playtest is complete when applicable.
- Balance Pass is complete when applicable.
- Documentation is updated.
- Blocking issues are resolved.

### Exit Criteria

- Work is merged or marked complete.
- Task status is accurate.
- Completion evidence is recorded.
- Changelog is updated when applicable.
- The stable project state remains consistent.

### Review Gate

Before merge, the maintainer must confirm:

- Definition of Done is satisfied.
- Scope is unchanged.
- Documentation is current.
- Tests or validation are recorded.
- No unrelated files are included.
- No blocking review comments remain.

### Scope Control

Merge must include only approved task work.

Unrelated cleanup, extra ideas, or opportunistic changes must be separated into their own tasks.

### Iteration Rules

If merge review finds a blocker, the task returns to the appropriate earlier phase.

Merge must not be used to bypass review.

## Phase 11: Release

### Purpose

The Release phase packages approved merged work into a player-facing or milestone-facing state.

Release confirms that the stable project state is coherent, documented, and ready for evaluation.

### Who Is Responsible

- Human project owner.
- Project Director.
- Release owner.
- Reviewer.
- Playtester.

### Required Documents

- `docs/GDD_MASTER.md`
- `docs/MVP_CHECKLIST.md`
- `docs/CHANGELOG.md`
- `docs/KNOWN_ISSUES.md`
- `docs/DEFINITION_OF_DONE.md`
- Relevant review records.

### Expected Outputs

- Release notes.
- Known issue summary.
- Completed task summary.
- Validation summary.
- MVP status update.
- Approval for release.

### Entry Criteria

- Required work is merged.
- Critical known issues are reviewed.
- MVP checklist status is current.
- Changelog is current.
- Required playtest and validation are complete.

### Exit Criteria

- Release status is recorded.
- Release notes are written.
- Known issues are documented.
- No critical undocumented behavior is present.
- MVP status is clear.

### Review Gate

The release owner must confirm:

- The release contains only approved work.
- The release does not include undocumented mechanics.
- The release does not contradict current documentation.
- The release has known issue visibility.
- The release has enough validation evidence.

### Scope Control

Release must not add new work.

Release is a packaging, validation, and communication phase only.

### Iteration Rules

If release validation fails, affected work returns to the appropriate earlier phase.

Critical release blockers must be resolved before release approval.

## Scope Control

Scope control applies to every phase.

Project Genesis is currently MVP-only. Every task must protect that constraint.

### Scope Control Checklist

- [ ] The work supports MVP goals.
- [ ] The work is documented.
- [ ] The work has approved decisions where needed.
- [ ] The work does not add unapproved mechanics.
- [ ] The work does not add unrelated systems.
- [ ] The work does not add unnecessary complexity.
- [ ] The work does not expand content requirements without approval.
- [ ] The work does not create extra implementation obligations.
- [ ] The work can be reviewed independently.
- [ ] The work can be validated with available criteria.

### Scope Expansion Handling

When scope expansion appears necessary:

1. Stop implementation.
2. Record the issue.
3. Return to Discussion.
4. Update decisions if approved.
5. Update documentation.
6. Create a separate task if needed.
7. Resume implementation only when the task is ready.

## Iteration Rules

Iteration is allowed when it improves clarity, correctness, stability, or documented quality.

Iteration must not be used to bypass approval.

### Iteration Checklist

- [ ] The iteration stays within approved scope.
- [ ] The reason for iteration is clear.
- [ ] The affected phase is identified.
- [ ] Required documents are updated.
- [ ] Review status is updated.
- [ ] The task status remains accurate.
- [ ] New ideas are separated from current task work.

### Returning to Earlier Phases

A task must return to an earlier phase when:

- A missing decision is discovered.
- Documentation is incomplete.
- Scope is unclear.
- Review identifies design conflict.
- Playtest identifies a blocking issue.
- Balance review identifies undocumented assumptions.
- Implementation requires unrelated work.

Returning to an earlier phase is normal production control. It is not a failure.

## Review Gates

Review gates prevent incomplete or undocumented work from moving forward.

### Gate 1: Idea Gate

- [ ] Idea is understandable.
- [ ] Idea has MVP relevance.
- [ ] Idea is not already rejected by current documentation.

### Gate 2: Discussion Gate

- [ ] Scope is clear.
- [ ] Risks are understood.
- [ ] Required decision path is known.

### Gate 3: Decision Gate

- [ ] Decision is recorded.
- [ ] Decision status is explicit.
- [ ] Affected systems are listed.

### Gate 4: Documentation Gate

- [ ] Source-of-truth documents are updated.
- [ ] Documentation does not exceed approval.
- [ ] Implementation guidance is sufficient.

### Gate 5: Ready Gate

- [ ] Task satisfies Definition of Ready.
- [ ] Acceptance criteria are testable.
- [ ] Dependencies are known.

### Gate 6: Implementation Gate

- [ ] Work matches task scope.
- [ ] Work follows architecture.
- [ ] Work includes validation.

### Gate 7: Internal Review Gate

- [ ] Review template is completed when applicable.
- [ ] Blocking issues are resolved.
- [ ] AI hallucination check is complete.

### Gate 8: Playtest Gate

- [ ] Human flow is validated when applicable.
- [ ] Blocking usability issues are resolved or assigned.
- [ ] Player-facing behavior matches documentation.

### Gate 9: Balance Gate

- [ ] Balance assumptions are documented.
- [ ] No fake numbers are introduced.
- [ ] No unapproved reward or scaling behavior is added.

### Gate 10: Merge Gate

- [ ] Definition of Done is satisfied.
- [ ] Documentation is current.
- [ ] Completion evidence is recorded.

### Gate 11: Release Gate

- [ ] Release notes are prepared.
- [ ] Known issues are visible.
- [ ] Release contains only approved work.

## Role Responsibilities

### Human Project Owner

- Approves major direction.
- Resolves final design authority conflicts.
- Approves releases.
- Confirms player-facing quality.

### Project Director

- Protects project vision.
- Enforces MVP scope.
- Rejects undocumented mechanics.
- Reviews consistency across documents.
- Confirms decisions are recorded.

### AI Assistants

- Read required documents before work.
- Follow approved scope.
- Avoid inventing mechanics.
- Implement or document only assigned work.
- Update relevant documentation.
- Provide completion evidence.

### Domain Agents

- Own quality in their domain.
- Check domain-specific documentation.
- Identify missing decisions.
- Escalate contradictions.

### Reviewer

- Reviews against requirements.
- Reviews against source-of-truth documents.
- Checks for scope creep.
- Checks for AI hallucination.
- Approves or rejects work based on evidence.

### Playtester

- Tests intended player flow.
- Records observed issues.
- Separates bugs from new ideas.
- Reports usability and progression concerns.

### Release Owner

- Confirms merged work is coherent.
- Confirms changelog and known issues are current.
- Confirms release evidence is available.
- Records release status.

## Workflow Checklists

### Contributor Start Checklist

- [ ] Read the task.
- [ ] Read relevant source-of-truth documents.
- [ ] Confirm MVP scope.
- [ ] Confirm acceptance criteria.
- [ ] Confirm dependencies.
- [ ] Confirm Definition of Ready.
- [ ] Identify required documentation updates.

### Contributor Finish Checklist

- [ ] Complete the approved task only.
- [ ] Update required documentation.
- [ ] Run or perform required validation.
- [ ] Record validation evidence.
- [ ] Check for unrelated file changes.
- [ ] Check for undocumented mechanics.
- [ ] Check Definition of Done.
- [ ] Submit for review.

### Reviewer Checklist

- [ ] Review task requirements.
- [ ] Review changed files.
- [ ] Review relevant documentation.
- [ ] Check for scope creep.
- [ ] Check for undocumented mechanics.
- [ ] Check architecture consistency.
- [ ] Check testing evidence.
- [ ] Check documentation accuracy.
- [ ] Approve or reject with clear reasoning.

### Release Checklist

- [ ] Required work is merged.
- [ ] MVP checklist is current.
- [ ] Changelog is current.
- [ ] Known issues are current.
- [ ] Playtest notes are reviewed.
- [ ] Balance notes are reviewed when applicable.
- [ ] Release notes are prepared.
- [ ] Release is approved.

## Professional Conclusion

Project Genesis uses a disciplined production workflow so that AI-assisted development remains coherent, reviewable, and aligned with the approved MVP.

Every phase exists to protect the project from unclear scope, undocumented mechanics, incomplete implementation, inconsistent documentation, and avoidable rework.

Work moves forward only when it is ready.

Work is complete only when it satisfies the Definition of Done.

All contributors are responsible for following this lifecycle exactly.
