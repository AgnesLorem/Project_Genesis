# Project Genesis Definition of Done

## Purpose

This document defines the official completion standard for Project Genesis tasks.

Every AI assistant, human contributor, reviewer, and project owner must use this document before marking any task complete.

A task is only considered **DONE** when it satisfies every applicable requirement in this document, aligns with the current approved project documentation, and has passed review without unresolved blocking issues.

This document is mandatory for:

- Gameplay implementation tasks.
- UI implementation tasks.
- Data schema tasks.
- Content authoring tasks.
- Documentation tasks.
- Art pipeline tasks.
- Technical architecture tasks.
- Review tasks.
- Production cleanup tasks.

No task may be marked complete because it is "mostly working," "good enough," "visually acceptable," or "ready for now."

Completion requires evidence.

## Definition of Done Philosophy

Project Genesis uses a documentation-first production model.

The repository documentation is the source of truth. Implementation must follow approved documentation, and documentation must reflect completed implementation.

The Definition of Done exists to prevent:

- Undocumented mechanics.
- Incomplete systems.
- Hidden technical debt.
- Scope drift.
- AI hallucination.
- Hardcoded gameplay values.
- Unreviewed changes.
- Unvalidated assumptions.
- Broken player progression.
- Inconsistent architecture.

For Project Genesis, a task is done only when it is:

- Correct.
- Documented.
- Tested.
- Reviewed.
- Scoped.
- Maintainable.
- Data-driven where applicable.
- Consistent with the approved MVP.

If any required condition is not satisfied, the task is **NOT DONE**.

## General Requirements

Every completed task must satisfy the following general requirements.

### General Checklist

- [ ] The task matches the approved request.
- [ ] The task stays within MVP scope.
- [ ] The task does not introduce undocumented mechanics.
- [ ] The task does not introduce unrelated changes.
- [ ] The task does not modify unrelated files.
- [ ] The task does not remove existing approved behavior unless explicitly required.
- [ ] The task does not contradict `docs/GDD_MASTER.md`.
- [ ] The task does not contradict `docs/DECISIONS.md`.
- [ ] The task follows `docs/PROJECT_PRINCIPLES.md`.
- [ ] The task follows `agents/AGENTS.md`.
- [ ] The task follows `docs/STYLE_GUIDE.md`.
- [ ] The task has a clear owner or responsible contributor.
- [ ] The task has a clear review status.
- [ ] The task has no unresolved blocking questions.
- [ ] The task has no hidden assumptions that affect gameplay, data, UI, saves, balance, or architecture.

### Completion Evidence

Every completed task must provide evidence that it is complete.

Acceptable evidence may include:

- File paths changed.
- Documentation sections updated.
- Test results.
- Review notes.
- Validation checklist results.
- Screenshots for UI tasks.
- Data validation notes for content tasks.
- Manual verification notes.

Completion evidence must be specific enough that another contributor can understand what changed and how it was verified.

## Programming Requirements

Programming tasks must satisfy all relevant engineering rules before they can be marked complete.

### Programming Checklist

- [ ] The implementation follows the approved architecture.
- [ ] Server-authoritative behavior remains server-authoritative.
- [ ] Gameplay logic is not placed inside UI-only code.
- [ ] UI code does not make authoritative gameplay decisions.
- [ ] Gameplay values are data-driven where applicable.
- [ ] No gameplay values are hardcoded unless explicitly documented and approved.
- [ ] Modules have clear responsibilities.
- [ ] Code is modular and maintainable.
- [ ] Code avoids unnecessary complexity.
- [ ] Code avoids duplicate logic unless duplication is intentional and documented.
- [ ] Code follows existing repository patterns.
- [ ] Code follows naming conventions from `docs/STYLE_GUIDE.md`.
- [ ] Code avoids undocumented side effects.
- [ ] Code does not rely on fragile ordering unless documented.
- [ ] Code handles invalid or missing data safely.
- [ ] Code does not trust client-provided gameplay authority.
- [ ] Code does not create new undocumented RemoteEvents or RemoteFunctions.
- [ ] Code does not bypass validation layers.
- [ ] Code has no obvious dead code.
- [ ] Code has no temporary debug behavior left in production paths.
- [ ] Code has no placeholder behavior presented as final behavior.
- [ ] Code has no TODO comments for required completion work.

### Architecture Checklist

- [ ] The change respects service ownership boundaries.
- [ ] The change separates gameplay logic from presentation.
- [ ] The change separates static data from runtime state.
- [ ] The change supports data-driven tuning.
- [ ] The change avoids coupling unrelated systems.
- [ ] The change can be reviewed in isolation.
- [ ] The change can be extended through documented data or approved modules.
- [ ] The change does not require rewriting unrelated systems.

## Documentation Requirements

Documentation is required for task completion.

No implementation task is complete until the documentation reflects the current behavior.

### Documentation Checklist

- [ ] Relevant documentation has been read before work begins.
- [ ] Relevant documentation has been updated after work is complete.
- [ ] Documentation changes match the implementation.
- [ ] Implementation does not exceed the documented design.
- [ ] Documentation does not claim unimplemented behavior is complete.
- [ ] New decisions are recorded in `docs/DECISIONS.md` when applicable.
- [ ] New unresolved questions are recorded in `docs/KNOWN_ISSUES.md` when applicable.
- [ ] Data changes are reflected in `docs/DATA_SCHEMA.md` when applicable.
- [ ] Combat changes are reflected in `docs/COMBAT.md` when applicable.
- [ ] Balance assumptions are reflected in `docs/BALANCE.md` when applicable.
- [ ] Content workflow changes are reflected in `docs/CONTENT_PIPELINE.md` when applicable.
- [ ] Technical architecture changes are reflected in `docs/TECH_ARCHITECTURE.md` when applicable.
- [ ] MVP checklist status is updated when applicable.
- [ ] Review records are created or updated when applicable.
- [ ] Documentation uses clear professional language.
- [ ] Documentation avoids speculative mechanics.
- [ ] Documentation avoids fake numeric values.
- [ ] Documentation avoids implementation details in design-only documents.

### Documentation Quality Checklist

- [ ] The document has a clear purpose.
- [ ] The document has clear headings.
- [ ] The document is easy to scan.
- [ ] The document uses consistent terminology.
- [ ] The document does not conflict with other source-of-truth documents.
- [ ] The document distinguishes approved facts from open questions.
- [ ] The document does not introduce mechanics through implication.
- [ ] The document does not use vague completion language.
- [ ] The document provides actionable review criteria.

## Gameplay Requirements

Gameplay tasks must be consistent with the approved MVP design.

### Gameplay Checklist

- [ ] The gameplay behavior is approved in `docs/GDD_MASTER.md`.
- [ ] The gameplay behavior is supported by `docs/DECISIONS.md`.
- [ ] The gameplay behavior supports player progression.
- [ ] The gameplay behavior does not add unapproved systems.
- [ ] The gameplay behavior does not add hidden mechanics.
- [ ] The gameplay behavior does not add new currencies unless documented and approved.
- [ ] The gameplay behavior does not add new resource systems unless documented and approved.
- [ ] The gameplay behavior does not add power gates where only recommendations are approved.
- [ ] The gameplay behavior preserves approved combat rules.
- [ ] The gameplay behavior preserves approved evolution rules.
- [ ] The gameplay behavior preserves approved collection rules.
- [ ] The gameplay behavior preserves approved economy rules.
- [ ] The gameplay behavior has clear player-facing outcomes.
- [ ] The gameplay behavior has clear data ownership.
- [ ] The gameplay behavior has no undocumented balance assumptions.
- [ ] The gameplay behavior has been tested through the relevant player flow.

### Gameplay Completion Evidence

Gameplay tasks must include evidence showing:

- What player action was tested.
- What result occurred.
- What data changed.
- What UI state changed, if applicable.
- What server-side state changed, if applicable.
- What documentation was updated.

If a gameplay task cannot provide this evidence, it is **NOT DONE**.

## Performance Requirements

Performance requirements apply to every task that affects runtime behavior, UI responsiveness, data loading, combat simulation, save flow, content loading, or repeated player actions.

### Performance Checklist

- [ ] The change avoids unnecessary repeated work.
- [ ] The change avoids unnecessary network traffic.
- [ ] The change avoids unnecessary client-server messages.
- [ ] The change avoids unnecessary data duplication.
- [ ] The change avoids expensive polling where event-driven behavior is appropriate.
- [ ] The change does not introduce visible UI lag during normal use.
- [ ] The change does not introduce avoidable memory growth.
- [ ] The change does not create unbounded loops.
- [ ] The change does not create unbounded tables, queues, or listeners.
- [ ] Repeated actions remain stable over multiple uses.
- [ ] Data loading remains predictable.
- [ ] Save-related behavior avoids excessive writes.
- [ ] Performance-sensitive assumptions are documented.

### Performance Evidence

Performance-sensitive tasks must include at least one applicable validation note:

- Manual runtime observation.
- Repeated action test.
- Client-server message review.
- Save write review.
- Data loading review.
- UI responsiveness review.
- Module lifecycle review.

## Security Requirements

Security requirements apply to all systems that accept player input, client messages, save data, inventory state, combat state, economy state, progression state, or content identifiers.

### Security Checklist

- [ ] The server remains authoritative.
- [ ] The client cannot grant progression.
- [ ] The client cannot grant currency.
- [ ] The client cannot grant inventory items.
- [ ] The client cannot grant creatures.
- [ ] The client cannot bypass combat outcomes.
- [ ] The client cannot bypass evolution requirements.
- [ ] The client cannot bypass collection requirements.
- [ ] Client requests are validated on the server.
- [ ] Invalid identifiers are rejected safely.
- [ ] Missing data is handled safely.
- [ ] Malformed requests do not corrupt player state.
- [ ] Save data is validated before use.
- [ ] Reward grants are controlled by approved server logic.
- [ ] Debug commands are not exposed to players.
- [ ] Administrative behavior is not added unless documented and approved.
- [ ] Sensitive internal state is not exposed unnecessarily.

### Security Evidence

Security-sensitive tasks must include notes describing:

- Which client inputs were validated.
- Which server checks were performed.
- Which invalid cases were tested.
- Which state changes are protected.

If authority boundaries are unclear, the task is **NOT DONE**.

## Testing Requirements

Testing is required before a task can be marked complete.

The level of testing should match the risk and scope of the change.

### Testing Checklist

- [ ] The primary success path has been tested.
- [ ] At least one relevant failure path has been tested.
- [ ] Invalid input has been tested where applicable.
- [ ] Missing data has been tested where applicable.
- [ ] Repeated use has been tested where applicable.
- [ ] Save/load behavior has been tested where applicable.
- [ ] UI state changes have been tested where applicable.
- [ ] Server authority has been tested where applicable.
- [ ] Data-driven configuration has been tested where applicable.
- [ ] No unrelated systems appear broken from the change.
- [ ] Test results are documented.
- [ ] Known untested areas are documented.

### Manual Testing Checklist

- [ ] The feature can be reached through the intended user flow.
- [ ] The feature behaves as documented.
- [ ] The feature handles expected player actions.
- [ ] The feature handles invalid or edge-case player actions.
- [ ] The feature returns to a stable state after completion.
- [ ] The feature does not block normal progression.
- [ ] The feature does not create incorrect rewards.
- [ ] The feature does not leave stale UI state.
- [ ] The feature does not require developer-only setup for normal use.

### Automated Testing Checklist

When automated testing exists for the relevant area:

- [ ] Existing tests pass.
- [ ] New tests are added for new logic where appropriate.
- [ ] Tests cover core behavior.
- [ ] Tests cover important failure cases.
- [ ] Tests avoid hardcoded assumptions that contradict data-driven design.
- [ ] Test names clearly describe behavior.

If automated testing does not exist for the relevant area, the contributor must document manual validation.

## Review Requirements

Every completed task must pass review.

Review exists to protect quality, scope, documentation, and consistency.

### Review Checklist

- [ ] The task was reviewed against the original request.
- [ ] The task was reviewed against `docs/GDD_MASTER.md`.
- [ ] The task was reviewed against `docs/DECISIONS.md`.
- [ ] The task was reviewed against `docs/PROJECT_PRINCIPLES.md`.
- [ ] The task was reviewed against `agents/AGENTS.md`.
- [ ] The task was reviewed against `docs/STYLE_GUIDE.md`.
- [ ] The task was reviewed for undocumented mechanics.
- [ ] The task was reviewed for feature creep.
- [ ] The task was reviewed for unrelated file changes.
- [ ] The task was reviewed for hardcoded gameplay values.
- [ ] The task was reviewed for architecture consistency.
- [ ] The task was reviewed for documentation accuracy.
- [ ] The task was reviewed for test coverage.
- [ ] The task was reviewed for player progression impact.
- [ ] The task was reviewed for AI hallucination.
- [ ] Blocking review issues have been resolved.
- [ ] Non-blocking review issues have been documented.

### Reviewer Responsibilities

The reviewer must confirm:

- The task is actually complete.
- The implementation matches the documented scope.
- The documentation is updated.
- The task does not introduce unapproved design.
- The task does not create avoidable maintenance risk.
- The task can be understood by another contributor.

Review approval must be based on evidence, not intent.

## Acceptance Criteria

Acceptance criteria define what the completed task must accomplish.

Every task must have acceptance criteria before it can be marked complete.

### Acceptance Criteria Checklist

- [ ] The acceptance criteria are written clearly.
- [ ] The acceptance criteria are specific.
- [ ] The acceptance criteria are testable.
- [ ] The acceptance criteria are limited to the approved scope.
- [ ] The acceptance criteria match the relevant documentation.
- [ ] The acceptance criteria avoid vague terms such as "better," "polished," or "improved" unless measurable context is provided.
- [ ] Each acceptance criterion has been verified.
- [ ] Any failed acceptance criterion is documented as blocking.

### Valid Acceptance Criteria

Valid acceptance criteria answer:

- What must exist?
- What must happen?
- What must not happen?
- What data must change?
- What documentation must change?
- What tests or validation must pass?

### Invalid Acceptance Criteria

Invalid acceptance criteria include:

- "Looks good."
- "Works for now."
- "Should be fine."
- "Mostly complete."
- "Ready unless someone finds something."
- "Will document later."
- "Needs cleanup after merge."

Any task using invalid acceptance criteria is **NOT DONE**.

## Merge Requirements

A task may only be merged or officially marked complete when every merge requirement is satisfied.

### Merge Checklist

- [ ] The task satisfies all applicable Definition of Done checklists.
- [ ] The task matches approved documentation.
- [ ] The task has no undocumented mechanics.
- [ ] The task has no unrelated file changes.
- [ ] The task has no unresolved blocking review comments.
- [ ] The task has no required documentation missing.
- [ ] The task has no required tests missing.
- [ ] The task has no known critical defects.
- [ ] The task has no unresolved authority or security concerns.
- [ ] The task has no hardcoded gameplay values unless explicitly approved.
- [ ] The task has clear completion evidence.
- [ ] The task has been reviewed using the review template when applicable.
- [ ] The MVP checklist has been updated when applicable.
- [ ] The changelog has been updated when applicable.
- [ ] The final status is explicitly marked as approved or complete.

### Merge Blockers

Any of the following block completion:

- Undocumented gameplay behavior.
- Unapproved scope expansion.
- Contradiction with the GDD.
- Contradiction with the decision log.
- Client-authoritative gameplay state.
- Hardcoded gameplay tuning where data-driven values are required.
- Missing required documentation.
- Missing required validation.
- Unresolved critical review issue.
- Unrelated file modifications.
- Placeholder behavior presented as complete.
- Known broken primary user flow.
- Save, economy, combat, or progression risk without review.

## Examples

The following examples define acceptable and unacceptable completion patterns.

## DONE

### Documentation Task Example

A documentation task is **DONE** when:

- [ ] The requested document exists in the correct folder.
- [ ] The document contains all required sections.
- [ ] The document uses professional production language.
- [ ] The document does not add unapproved mechanics.
- [ ] The document is consistent with existing source-of-truth documents.
- [ ] The document is formatted consistently with repository standards.
- [ ] The document has been checked for missing required headings.

Example completion statement:

> Created `docs/DEFINITION_OF_DONE.md` with the required production completion standards, checklists, review requirements, merge requirements, and DONE / NOT DONE examples. Verified that the document contains all requested sections and does not introduce gameplay mechanics.

### Gameplay Task Example

A gameplay task is **DONE** when:

- [ ] The behavior is already approved in documentation.
- [ ] The implementation follows server-authoritative architecture.
- [ ] Gameplay values come from documented data where applicable.
- [ ] The relevant player flow has been tested.
- [ ] Invalid inputs have been tested.
- [ ] Documentation has been updated.
- [ ] Review found no blocking issues.

Example completion statement:

> Implemented the approved combat behavior exactly as documented, validated server-side authority, tested the expected battle flow, updated relevant combat documentation, and resolved review feedback.

### Data Task Example

A data task is **DONE** when:

- [ ] The data follows `docs/DATA_SCHEMA.md`.
- [ ] Required fields are present.
- [ ] Field types are correct.
- [ ] Required identifiers are stable.
- [ ] Invalid references are handled or documented.
- [ ] Data changes are reviewed for balance impact.
- [ ] Data changes are reflected in relevant documentation.

Example completion statement:

> Added the requested data entries using the documented schema, confirmed required fields and identifiers, checked references, and updated the relevant documentation.

### UI Task Example

A UI task is **DONE** when:

- [ ] The UI presents approved gameplay state only.
- [ ] The UI does not make authoritative gameplay decisions.
- [ ] The UI follows documented style and naming rules.
- [ ] The UI works through the intended player flow.
- [ ] The UI handles loading, empty, and invalid states where applicable.
- [ ] The UI has been visually checked.
- [ ] Documentation has been updated where behavior changed.

Example completion statement:

> Built the requested UI flow, verified it reads approved state, confirmed it does not grant gameplay outcomes, checked normal and empty states, and updated documentation.

## NOT DONE

### Undocumented Mechanic Example

A task is **NOT DONE** if:

- [ ] It adds a new gameplay rule not approved in documentation.
- [ ] It changes progression behavior without updating the GDD.
- [ ] It adds a new reward path without decision approval.
- [ ] It assumes a balance value without recording it.

Invalid completion statement:

> Added an extra reward because it felt better.

Reason:

The change introduces undocumented gameplay behavior and bypasses design approval.

### Incomplete Documentation Example

A task is **NOT DONE** if:

- [ ] The implementation is complete but documentation is unchanged.
- [ ] Documentation describes behavior that was not implemented.
- [ ] Documentation omits a new approved decision.
- [ ] Documentation leaves required sections blank.

Invalid completion statement:

> Code is working; docs can be updated separately.

Reason:

Project Genesis requires documentation to be updated before completion.

### Unverified Implementation Example

A task is **NOT DONE** if:

- [ ] The contributor did not test the primary flow.
- [ ] The contributor did not test relevant failure cases.
- [ ] The contributor did not document validation results.
- [ ] The contributor cannot explain how completion was verified.

Invalid completion statement:

> It should work based on inspection.

Reason:

Inspection alone is not sufficient completion evidence for implementation tasks.

### Scope Creep Example

A task is **NOT DONE** if:

- [ ] It includes extra systems not requested.
- [ ] It modifies unrelated files.
- [ ] It changes architecture outside the task scope.
- [ ] It adds content unrelated to the approved task.

Invalid completion statement:

> I also added a few related systems while I was there.

Reason:

Unapproved expansion violates scope control.

### Placeholder Completion Example

A task is **NOT DONE** if:

- [ ] Required behavior is stubbed.
- [ ] Placeholder data is presented as final.
- [ ] Temporary UI is presented as production-ready.
- [ ] TODO comments remain for required behavior.
- [ ] The task requires another pass before it satisfies acceptance criteria.

Invalid completion statement:

> The structure is there; the real behavior can be filled in afterward.

Reason:

Task structure alone is not completion unless the task only requested structure.

## Final Completion Gate

Before any task is marked complete, the contributor must answer the following questions.

### Final Gate Checklist

- [ ] Did I read the relevant source-of-truth documents?
- [ ] Did I stay within the approved task scope?
- [ ] Did I avoid unrelated file changes?
- [ ] Did I avoid undocumented mechanics?
- [ ] Did I avoid hardcoded gameplay values where data-driven values are required?
- [ ] Did I preserve server authority where applicable?
- [ ] Did I update relevant documentation?
- [ ] Did I validate the primary behavior?
- [ ] Did I validate relevant failure cases?
- [ ] Did I document test or validation results?
- [ ] Did I complete review requirements?
- [ ] Did I resolve blocking review issues?
- [ ] Did I update task status accurately?
- [ ] Can another contributor understand what changed and why?
- [ ] Can another contributor verify completion from the evidence provided?

If the answer to any required question is no, the task is **NOT DONE**.

## Professional Conclusion

Project Genesis treats completion as a production standard, not a personal judgment.

A completed task must be aligned with the approved design, implemented or documented to the required quality level, validated through evidence, reviewed for consistency, and ready for another contributor to build upon without guessing.

The Definition of Done protects the project from accidental complexity, inconsistent documentation, incomplete systems, and unapproved design drift.

Every contributor is responsible for applying this standard before marking work complete.
