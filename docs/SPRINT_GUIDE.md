# Project Genesis Sprint Guide

## Purpose

This document defines how development sprints are organized for Project Genesis.

It provides the sprint operating model for AI assistants, human developers, reviewers, designers, and project leadership.

Project Genesis is currently in MVP production. Every sprint must protect MVP scope, follow the documentation-first workflow, and avoid undocumented gameplay.

This document is professional agile process documentation only.

It does not define gameplay mechanics.

## Status

- Document Status: Active
- Scope: MVP sprint planning and execution
- Project Type: Roblox
- Owner: Project Director
- Last Updated: 2026-06-28

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Sprint Philosophy](#sprint-philosophy)
- [Sprint Types](#sprint-types)
- [Sprint Planning](#sprint-planning)
- [Task Assignment](#task-assignment)
- [Daily Workflow](#daily-workflow)
- [Review Process](#review-process)
- [Sprint Retrospective](#sprint-retrospective)
- [Bug Fix Sprint](#bug-fix-sprint)
- [Feature Sprint](#feature-sprint)
- [Priority Rules](#priority-rules)
- [MVP Priority](#mvp-priority)
- [Sprint Entry Criteria](#sprint-entry-criteria)
- [Sprint Exit Criteria](#sprint-exit-criteria)
- [Sprint Checklists](#sprint-checklists)
- [Professional Conclusion](#professional-conclusion)

## Sprint Philosophy

Project Genesis sprints are short, focused production cycles used to move approved MVP work from ready state to reviewed completion.

Sprints exist to create momentum without losing control of scope.

Every sprint must follow:

- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/DEVELOPMENT_WORKFLOW.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/MVP_CHECKLIST.md`
- `docs/MILESTONES.md`
- `agents/AGENTS.md`

### Core Sprint Principles

- MVP scope comes first.
- Documentation is the source of truth.
- Tasks must be ready before sprint commitment.
- Work must be reviewable.
- Work must be testable or verifiable.
- AI assistants must not invent mechanics.
- Contributors must not modify unrelated files.
- Implementation must not begin before required decisions and documentation exist.
- Review must happen before work is marked complete.
- Sprint success is measured by accepted work, not started work.

## Sprint Types

Project Genesis supports multiple sprint types.

Each sprint must declare its type before planning begins.

### Supported Sprint Types

| Sprint Type | Purpose |
|---|---|
| Foundation Sprint | Builds documentation, architecture, workflow, and setup needed for production |
| Feature Sprint | Implements approved MVP features or systems |
| Bug Fix Sprint | Resolves defects, regressions, validation failures, or blocking issues |
| Content Sprint | Adds approved MVP content through documented data workflows |
| Review Sprint | Focuses on review, validation, documentation alignment, and cleanup |
| Release Sprint | Prepares a release candidate for approval |

### Sprint Type Rules

- A sprint may have one primary type.
- Mixed work is allowed only if it supports the sprint goal.
- Bug fixes may interrupt a sprint when they block MVP progress.
- Feature work must not be used to add unapproved systems.
- Content work must follow `docs/CONTENT_PIPELINE.md`.
- Release work must not add new scope.

## Sprint Planning

Sprint Planning defines the sprint goal, task set, priorities, dependencies, ownership, and review plan.

No task should enter a sprint unless it satisfies Definition of Ready or has an explicit planning action to become ready.

### Responsible Roles

- Project Director.
- Human project owner.
- Relevant AI assistants.
- Domain agents.
- Reviewer Agent.
- Assigned developers.

### Required Inputs

- Current milestone from `docs/MILESTONES.md`.
- Current task status from `docs/MVP_CHECKLIST.md`.
- Relevant task files.
- Known issues from `docs/KNOWN_ISSUES.md`.
- Current design decisions from `docs/DECISIONS.md`.
- Definition of Ready from `docs/DEVELOPMENT_WORKFLOW.md`.
- Definition of Done from `docs/DEFINITION_OF_DONE.md`.

### Sprint Planning Outputs

- Sprint goal.
- Sprint type.
- Committed task list.
- Stretch task list, if any.
- Task owners.
- Reviewers.
- Dependencies.
- Risks.
- Blockers.
- Required documentation updates.
- Required testing or validation.
- Sprint exit criteria.

### Planning Checklist

- [ ] Sprint goal is clear.
- [ ] Sprint type is declared.
- [ ] Sprint supports the active MVP milestone.
- [ ] Selected tasks are within MVP scope.
- [ ] Selected tasks satisfy Definition of Ready.
- [ ] Task dependencies are known.
- [ ] Task owners are assigned.
- [ ] Reviewers are assigned.
- [ ] Required documents are identified.
- [ ] Known risks are documented.
- [ ] Blockers are documented.
- [ ] Sprint exit criteria are defined.

## Task Assignment

Task Assignment defines who owns each task and who reviews it.

Every sprint task must have one primary owner.

AI assistants may execute tasks, but they must follow the same ownership, documentation, and review standards as human contributors.

### Assignment Rules

- Each task has one primary owner.
- Each task has at least one reviewer when review is required.
- Domain-sensitive tasks must include the relevant domain owner.
- Security-sensitive tasks must include security review.
- Economy-sensitive tasks must include economy review.
- Combat-sensitive tasks must include combat review.
- Data-sensitive tasks must include data review.
- UI-sensitive tasks must include UI review.
- Documentation-sensitive tasks must include documentation review.

### Task Ownership Table

| Task Type | Primary Owner | Required Reviewer |
|---|---|---|
| Gameplay system task | Gameplay Agent or assigned developer | Reviewer Agent, Project Director when scope-sensitive |
| UI task | UI Agent or assigned developer | Reviewer Agent, Gameplay Agent when state is gameplay-facing |
| Economy task | Economy Agent or assigned developer | Reviewer Agent, Data Agent |
| Data schema task | Data Agent or assigned developer | Reviewer Agent, relevant domain owner |
| Security task | Technical owner or assigned developer | Reviewer Agent, Project Director |
| Documentation task | Assigned documentation owner | Reviewer Agent or Project Director |
| Content task | Data Agent or assigned content owner | Domain owner, Reviewer Agent |
| Bug fix | Assigned developer | Reviewer Agent, affected domain owner |

### Assignment Checklist

- [ ] Task owner is assigned.
- [ ] Reviewer is assigned.
- [ ] Domain owner is identified.
- [ ] Dependencies are clear.
- [ ] Required documents are listed.
- [ ] Acceptance criteria are clear.
- [ ] Completion evidence expectations are clear.

## Daily Workflow

The Daily Workflow defines how contributors should work during a sprint.

The goal is to keep work visible, scoped, validated, and aligned.

### Start-of-Day Workflow

1. Review sprint goal.
2. Review assigned task.
3. Read relevant source-of-truth documents.
4. Confirm task scope.
5. Confirm dependencies.
6. Confirm whether any blockers exist.
7. Begin only the approved task.

### During-Work Rules

- Stay within task scope.
- Do not add undocumented mechanics.
- Do not modify unrelated files.
- Do not hardcode gameplay values.
- Do not skip validation.
- Update documentation when behavior changes.
- Log blockers as soon as they appear.
- Return to Discussion or Documentation if design is missing.

### End-of-Day Workflow

1. Record progress.
2. Record blockers.
3. Record validation performed.
4. Record documentation changes needed or completed.
5. Update task status.
6. Submit completed work for review when ready.

### Daily Status Format

Daily status should answer:

- What was completed?
- What is in progress?
- What is blocked?
- What changed in documentation?
- What needs review?
- What risks were discovered?

### Daily Workflow Checklist

- [ ] Current task is understood.
- [ ] Required docs were checked.
- [ ] Scope remains unchanged.
- [ ] Progress is recorded.
- [ ] Blockers are recorded.
- [ ] Validation notes are recorded.
- [ ] Review needs are identified.
- [ ] Task status is accurate.

## Review Process

Review is required before sprint work can be marked complete.

Review exists to verify requirements, scope, architecture, documentation, testing, and MVP alignment.

### Required Review Documents

- `reviews/review_template.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/MVP_CHECKLIST.md`
- Relevant domain documentation.

### Review Flow

1. Contributor submits work with completion evidence.
2. Reviewer checks task requirements.
3. Reviewer checks source-of-truth alignment.
4. Reviewer checks changed files.
5. Reviewer checks testing or validation notes.
6. Reviewer checks documentation updates.
7. Reviewer identifies blocking and non-blocking issues.
8. Work is approved, rejected, or returned for revision.

### Review Checklist

- [ ] Task matches sprint goal.
- [ ] Task matches approved scope.
- [ ] Task satisfies acceptance criteria.
- [ ] Task satisfies Definition of Done.
- [ ] Relevant documentation is updated.
- [ ] No undocumented mechanics are introduced.
- [ ] No unrelated files are changed.
- [ ] No hardcoded gameplay values are introduced.
- [ ] Server authority is preserved where applicable.
- [ ] Data-driven rules are followed where applicable.
- [ ] Testing or validation evidence is present.
- [ ] Known risks are documented.

### Review Outcomes

| Outcome | Meaning |
|---|---|
| Approved | Work satisfies requirements and can be counted as complete |
| Approved With Notes | Work is complete, but non-blocking follow-up is recorded |
| Rejected | Work has blocking issues and is not complete |
| Return To Design | Work exposes missing or conflicting design |
| Return To Documentation | Documentation is missing, unclear, or inconsistent |

## Sprint Retrospective

Sprint Retrospective reviews the sprint after completion.

The goal is to improve production quality, not assign blame.

### Responsible Roles

- Project Director.
- Human project owner.
- Contributors.
- Reviewers.
- Relevant AI assistants.

### Retrospective Inputs

- Sprint goal.
- Completed tasks.
- Incomplete tasks.
- Review notes.
- Playtest notes when applicable.
- Known issues.
- Blockers.
- Documentation gaps.
- Validation results.

### Retrospective Questions

- Did the sprint meet its goal?
- Were tasks properly scoped?
- Were tasks ready before implementation?
- Did any work require missing decisions?
- Did any work introduce review churn?
- Did documentation stay current?
- Did AI assistants follow repository rules?
- Were blockers surfaced early?
- Did MVP priority remain clear?
- What should change in the next sprint?

### Retrospective Outputs

- Sprint result.
- Completed work summary.
- Incomplete work summary.
- Process improvements.
- Documentation updates.
- New known issues.
- Follow-up tasks.
- Priority changes.

### Retrospective Checklist

- [ ] Sprint goal was reviewed.
- [ ] Completed tasks were confirmed.
- [ ] Incomplete tasks were reviewed.
- [ ] Blockers were reviewed.
- [ ] Documentation gaps were recorded.
- [ ] Scope control issues were recorded.
- [ ] Review quality was assessed.
- [ ] Follow-up actions were assigned.

## Bug Fix Sprint

A Bug Fix Sprint focuses on defects, regressions, validation failures, broken workflows, security problems, or release blockers.

Bug Fix Sprints must remain narrow and evidence-driven.

### Bug Fix Sprint Goals

- Restore intended behavior.
- Resolve blocking defects.
- Protect save data.
- Protect server authority.
- Protect progression integrity.
- Protect economy integrity.
- Improve stability.
- Reduce release risk.

### Bug Fix Sprint Rules

- Fix only documented issues.
- Do not add new features.
- Do not redesign systems unless approved.
- Reproduce the issue when possible.
- Identify root cause.
- Validate the fix.
- Update documentation if documented behavior changes.
- Add or update known issue notes when unresolved risk remains.

### Bug Fix Sprint Checklist

- [ ] Bug or issue is documented.
- [ ] Severity is assigned.
- [ ] Affected systems are identified.
- [ ] Reproduction steps are known or limitation is documented.
- [ ] Fix scope is narrow.
- [ ] Regression risk is reviewed.
- [ ] Fix is validated.
- [ ] Relevant documentation is updated.
- [ ] Review is complete.

## Feature Sprint

A Feature Sprint focuses on approved MVP feature work.

Feature Sprints must only include features that are documented, scoped, and ready.

### Feature Sprint Goals

- Implement approved MVP functionality.
- Improve core loop completeness.
- Advance active milestone goals.
- Maintain data-driven architecture.
- Preserve server authority.
- Keep documentation current.

### Feature Sprint Rules

- Feature must be approved before implementation.
- Feature must satisfy Definition of Ready.
- Feature must have acceptance criteria.
- Feature must have a task owner.
- Feature must have a reviewer.
- Feature must not include unrelated cleanup.
- Feature must not include undocumented mechanics.
- Feature must update documentation after implementation.

### Feature Sprint Checklist

- [ ] Feature is approved in source-of-truth documentation.
- [ ] Feature supports active MVP milestone.
- [ ] Feature has clear acceptance criteria.
- [ ] Feature has known dependencies.
- [ ] Feature has task owner and reviewer.
- [ ] Feature follows architecture rules.
- [ ] Feature follows data-driven rules.
- [ ] Feature follows security rules where applicable.
- [ ] Feature is validated.
- [ ] Feature is reviewed.

## Priority Rules

Priority determines sprint order.

Priority must be based on MVP impact, dependency importance, risk reduction, and release readiness.

### Priority Levels

Project Genesis uses the priority model from `docs/MVP_CHECKLIST.md`.

| Priority | Meaning |
|---|---|
| P0 | Required for MVP foundation, implementation safety, or release viability |
| P1 | Required for MVP usability, completeness, or validation |
| P2 | Important polish, support work, or quality improvement after critical MVP needs |

### Priority Order

When choosing work, prioritize:

1. Blockers to active milestone.
2. P0 tasks.
3. Security or save integrity risks.
4. Data and architecture dependencies.
5. P1 tasks required for MVP usability.
6. Review and validation work blocking merge.
7. P2 polish only after core MVP tasks are stable.

### Priority Rules Checklist

- [ ] P0 work is handled before P1 work unless dependency order requires otherwise.
- [ ] P1 work is handled before P2 work unless risk requires otherwise.
- [ ] Release blockers override normal priority.
- [ ] Security and save integrity issues override feature work.
- [ ] Documentation blockers override implementation work.
- [ ] Scope control issues override convenience work.
- [ ] Polish does not displace required MVP functionality.

## MVP Priority

MVP Priority defines how sprint work should be evaluated against the current product goal.

The MVP exists to prove the core Project Genesis experience, not to deliver every desirable system.

### MVP Priority Rules

- Work that proves or protects the core loop has highest priority.
- Work required for server authority has high priority.
- Work required for data-driven gameplay has high priority.
- Work required for save integrity has high priority.
- Work required for reviewability has high priority.
- Work required for player comprehension has high priority.
- Work outside approved MVP scope is not eligible for sprint commitment.
- Work that adds complexity without MVP value must be rejected or deferred.

### MVP Priority Questions

Before adding a task to a sprint, ask:

- Does this support the active MVP milestone?
- Does this support the approved core loop?
- Does this protect architecture, data, saves, security, or review quality?
- Is this documented?
- Is this ready?
- Can this be completed and reviewed inside the sprint?
- Would delaying this block MVP progress?
- Does this add complexity that the MVP does not need?

### MVP Priority Checklist

- [ ] Task supports MVP scope.
- [ ] Task supports the active milestone.
- [ ] Task has documented purpose.
- [ ] Task is not speculative.
- [ ] Task does not introduce feature creep.
- [ ] Task can be validated.
- [ ] Task can be reviewed.

## Sprint Entry Criteria

A sprint may begin only when planning is complete.

### Entry Checklist

- [ ] Sprint goal is defined.
- [ ] Sprint type is defined.
- [ ] Active milestone is identified.
- [ ] Committed tasks are listed.
- [ ] Task owners are assigned.
- [ ] Reviewers are assigned.
- [ ] Dependencies are documented.
- [ ] Risks are documented.
- [ ] Blockers are documented.
- [ ] Required documents are identified.
- [ ] Definition of Ready is checked for committed tasks.

## Sprint Exit Criteria

A sprint may close when its results are recorded.

Tasks may remain incomplete, but their status must be honest and visible.

### Exit Checklist

- [ ] Completed tasks are marked accurately.
- [ ] Incomplete tasks are marked accurately.
- [ ] Review status is recorded.
- [ ] Validation evidence is recorded.
- [ ] Documentation updates are completed or tracked.
- [ ] Known issues are updated.
- [ ] Blockers are updated.
- [ ] Retrospective is completed.
- [ ] Follow-up tasks are created where needed.
- [ ] Sprint result is summarized.

## Sprint Checklists

### Sprint Planning Checklist

- [ ] Review active milestone.
- [ ] Review MVP checklist.
- [ ] Review known issues.
- [ ] Select sprint type.
- [ ] Define sprint goal.
- [ ] Select ready tasks.
- [ ] Assign owners.
- [ ] Assign reviewers.
- [ ] Identify dependencies.
- [ ] Identify risks.
- [ ] Confirm scope.

### Contributor Checklist

- [ ] Read assigned task.
- [ ] Read relevant documentation.
- [ ] Confirm scope.
- [ ] Complete only assigned work.
- [ ] Avoid unrelated changes.
- [ ] Update documentation.
- [ ] Validate work.
- [ ] Record evidence.
- [ ] Submit for review.

### Reviewer Checklist

- [ ] Review task requirements.
- [ ] Review changed files.
- [ ] Review source-of-truth alignment.
- [ ] Review validation evidence.
- [ ] Review documentation updates.
- [ ] Check for feature creep.
- [ ] Check for undocumented mechanics.
- [ ] Approve, reject, or return for revision.

### Retrospective Checklist

- [ ] Sprint goal reviewed.
- [ ] Completed work reviewed.
- [ ] Incomplete work reviewed.
- [ ] Blockers reviewed.
- [ ] Process issues recorded.
- [ ] Documentation gaps recorded.
- [ ] Follow-up tasks assigned.
- [ ] Next sprint risks identified.

## Professional Conclusion

Project Genesis sprints exist to turn approved MVP work into reviewed, validated, documented progress.

The sprint process must stay disciplined: plan only ready work, assign clear owners, validate every completed task, review before completion, and protect MVP scope at every step.

No sprint may be used to add undocumented gameplay, bypass documentation, or expand scope without approval.
