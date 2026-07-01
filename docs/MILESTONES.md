# Project Genesis MVP Milestones

## Purpose

This document defines the production milestones for the Project Genesis MVP.

Milestones are used to organize work, confirm production readiness, control scope, and ensure the MVP advances through clear review gates.

This document is not a feature list by itself. It does not approve new mechanics, new content categories, or implementation details beyond the current MVP scope.

All milestone work must remain consistent with:

- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/DEVELOPMENT_WORKFLOW.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/MVP_CHECKLIST.md`

## Status

- Document Status: Active
- Scope: MVP production planning
- Project Type: Roblox
- Owner: Project Director
- Last Updated: 2026-06-28

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Milestone Philosophy](#milestone-philosophy)
- [Milestone Overview](#milestone-overview)
- [Milestone 0: Project Foundation](#milestone-0-project-foundation)
- [Milestone 1: First Playable](#milestone-1-first-playable)
- [Milestone 2: Combat Prototype](#milestone-2-combat-prototype)
- [Milestone 3: Vertical Slice](#milestone-3-vertical-slice)
- [Milestone 4: Content Complete](#milestone-4-content-complete)
- [Milestone 5: MVP Release](#milestone-5-mvp-release)
- [Milestone Review Rules](#milestone-review-rules)
- [Scope Control](#scope-control)
- [Professional Conclusion](#professional-conclusion)

## Milestone Philosophy

Project Genesis milestones are production gates.

Each milestone must prove a specific level of readiness before the project advances.

A milestone is not complete because work has started. A milestone is complete only when its deliverables are present, reviewed, validated, documented, and accepted.

The MVP milestone plan is designed to:

- Protect the core project vision.
- Keep production focused on the MVP.
- Prevent undocumented mechanics.
- Prevent premature content expansion.
- Validate systems before scaling content.
- Keep gameplay values data-driven.
- Keep Roblox gameplay server-authoritative.
- Keep implementation separate from UI presentation.
- Keep documentation current with project state.
- Give AI assistants and human contributors a shared production sequence.

## Milestone Overview

| Milestone | Name | Production Purpose |
|---|---|---|
| Milestone 0 | Project Foundation | Establish documentation, architecture, scope, workflow, and repository standards |
| Milestone 1 | First Playable | Create a minimal playable path through approved MVP flow |
| Milestone 2 | Combat Prototype | Validate approved combat rules in a controlled prototype state |
| Milestone 3 | Vertical Slice | Prove the core MVP loop end-to-end with representative quality |
| Milestone 4 | Content Complete | Complete all approved MVP content and required supporting data |
| Milestone 5 | MVP Release | Final validation, polish, review, and release readiness |

## Milestone 0: Project Foundation

### Goal

Establish the project foundation required for safe AI-assisted and human-assisted MVP production.

Milestone 0 ensures the repository has the documentation, standards, workflow, ownership, and planning structure required before gameplay implementation begins.

### Requirements

- Source-of-truth documentation exists.
- AI assistant rules exist.
- Production workflow exists.
- Definition of Done exists.
- Security principles exist.
- Configuration standards exist.
- Data schema documentation exists.
- Review process exists.
- MVP checklist exists.
- Known issues are tracked.
- Architecture direction is documented.
- Scope control rules are documented.

### Deliverables

- `docs/GDD_MASTER.md`
- `docs/DECISIONS.md`
- `docs/PROJECT_PRINCIPLES.md`
- `docs/DEVELOPMENT_WORKFLOW.md`
- `docs/DEFINITION_OF_DONE.md`
- `docs/TECH_ARCHITECTURE.md`
- `docs/DATA_SCHEMA.md`
- `docs/SECURITY_GUIDE.md`
- `docs/CONFIG_GUIDE.md`
- `docs/CONFIG_STRUCTURE.md`
- `docs/MVP_CHECKLIST.md`
- `docs/KNOWN_ISSUES.md`
- `docs/STYLE_GUIDE.md`
- `reviews/review_template.md`
- Agent role documentation in `agents/`

### Exit Criteria

- [ ] Required foundation documents exist.
- [ ] MVP scope is clearly documented.
- [ ] Out-of-scope rules are clearly documented.
- [ ] AI assistant operating rules are documented.
- [ ] Review process is documented.
- [ ] Definition of Ready and Definition of Done are documented.
- [ ] Data-driven architecture principles are documented.
- [ ] Server-authoritative principles are documented.
- [ ] Configuration hierarchy is documented.
- [ ] Known unresolved questions are tracked.
- [ ] No gameplay implementation is required to complete this milestone.

### Dependencies

- Project owner approval of documentation-first process.
- Project Director review.
- Agreement that documentation is the source of truth.
- Agreement that MVP scope is protected.

### Review Checklist

- [ ] Documentation is professional and internally consistent.
- [ ] Documentation does not invent unapproved mechanics.
- [ ] Documentation clearly separates approved scope from unresolved questions.
- [ ] Documentation identifies required review gates.
- [ ] Documentation supports AI-assisted collaboration.
- [ ] Documentation supports server-authoritative Roblox architecture.
- [ ] Documentation supports data-driven gameplay.
- [ ] MVP checklist reflects required production categories.

### Risks

- Documentation may become too broad and imply unapproved scope.
- Reserved systems may be mistaken for active MVP approval.
- AI assistants may skip required reading.
- Technical architecture may remain too abstract for implementation planning.
- MVP checklist may require refinement before implementation tasks begin.

## Milestone 1: First Playable

### Goal

Create the first playable MVP path that allows a player to enter the game, see approved game state, interact with the core UI flow, and complete a minimal documented progression path.

First Playable is about proving that the project can run as a coherent game shell with server-owned state and data-driven content access.

### Requirements

- Roblox project structure is established.
- Core services or equivalent architecture are defined.
- Static data loading path is established.
- Player data lifecycle is defined and functional enough for MVP validation.
- Minimal UI flow exists for approved MVP interaction.
- Player state is server-owned.
- Client presentation does not own gameplay authority.
- Configuration data is used for gameplay-facing values.
- First playable path is documented.
- Required validation notes are recorded.

### Deliverables

- Approved source folder structure.
- Minimal service lifecycle pattern.
- Minimal static data registry or equivalent data-loading path.
- Minimal player save lifecycle path.
- Minimal UI shell for approved MVP flow.
- Minimal player progression state display.
- Initial playable validation notes.
- Updated `docs/MVP_CHECKLIST.md`.
- Updated relevant documentation for any implemented architecture decisions.

### Exit Criteria

- [ ] The project can be opened and run in the intended Roblox development environment.
- [ ] A player can enter the experience.
- [ ] Server-owned player state is initialized.
- [ ] Data-driven configuration can be loaded or referenced through the approved path.
- [ ] UI can display approved state without owning authority.
- [ ] A minimal approved player flow can be completed.
- [ ] Save lifecycle behavior is documented and validated at the appropriate MVP level.
- [ ] No combat-specific completion is required unless explicitly included in the approved task scope.
- [ ] No undocumented mechanics are introduced.
- [ ] Validation evidence is recorded.

### Dependencies

- Milestone 0 completion.
- Source folder structure approval.
- Technical architecture approval.
- Save system design approval.
- Data schema approval.
- UI guideline expansion for required MVP screens.
- Security guide acceptance.

### Review Checklist

- [ ] First playable path matches approved MVP scope.
- [ ] UI is presentation-only for gameplay authority.
- [ ] Server owns gameplay-relevant state.
- [ ] Data path supports configuration-driven values.
- [ ] Save lifecycle does not trust client state.
- [ ] No hardcoded gameplay values are introduced.
- [ ] No unapproved gameplay systems are added.
- [ ] Documentation reflects implemented structure.
- [ ] Manual validation notes are present.

### Risks

- First playable may accidentally become a full feature pass.
- UI may begin to own gameplay decisions.
- Save behavior may be implemented before all persistence rules are documented.
- Data loading may become too specific to early content.
- Temporary placeholders may be mistaken for production behavior.

## Milestone 2: Combat Prototype

### Goal

Validate the approved MVP combat rules in a controlled prototype state.

Combat Prototype proves that the auto battle structure, Action Time Bar, SPD-driven gauge filling, cooldown skills, server authority, battle size rules, simplified damage model, full post-battle healing, simple enemy AI, boss phase support, and auto retry support can work according to documentation.

### Requirements

- Combat rules follow `docs/COMBAT.md`.
- Combat uses approved data schemas.
- Combat values come from configuration.
- Combat outcome authority stays on the server.
- Story Mode supports approved 1v1 rules.
- Boss or Challenge combat supports approved 3v3 rules when included in task scope.
- Recommended Power is guidance only.
- No power gate is introduced.
- DEF reduction follows documented percentage-based design.
- Damage formula uses documented placeholders or approved values only.
- No mana is introduced.
- Skill cooldown behavior is documented and validated.
- Enemy AI remains intentionally simple.
- Creature full heal after battle is supported where applicable.

### Deliverables

- Combat prototype task completion records.
- Combat data references.
- Combat validation notes.
- Server authority validation notes.
- Updated combat documentation if implementation clarifies approved behavior.
- Updated balance notes for unknown or placeholder values.
- Updated MVP checklist status.
- Internal review record.

### Exit Criteria

- [ ] Auto battle behavior is represented according to approved rules.
- [ ] Action Time Bar behavior is represented according to approved rules.
- [ ] SPD affects gauge fill according to documented design.
- [ ] Cooldown skills are represented without mana.
- [ ] Story battle size follows approved 1v1 rules.
- [ ] Boss or Challenge battle size follows approved 3v3 rules when included.
- [ ] Damage calculation does not trust client damage.
- [ ] Battle results are server-authoritative.
- [ ] Recommended Power remains guidance only.
- [ ] Creature post-battle healing follows approved rules.
- [ ] Enemy AI remains simple and documented.
- [ ] Boss phase behavior is documented if included.
- [ ] Auto Retry behavior is documented if included.
- [ ] Combat validation evidence is recorded.

### Dependencies

- Milestone 1 completion.
- Combat formula values or approved placeholders.
- Action Gauge behavior definition.
- Auto battle decision rules.
- Creature runtime model.
- Skill schema and skill config rules.
- Balance review for combat variables.
- Security review for combat remotes and authority.

### Review Checklist

- [ ] Combat follows `docs/COMBAT.md`.
- [ ] Combat does not introduce manual battle commands unless approved.
- [ ] Combat does not introduce mana.
- [ ] Combat does not introduce power gates.
- [ ] Combat does not trust client damage, victory, rewards, or cooldowns.
- [ ] Combat values are data-driven.
- [ ] Battle mode sizes match approved rules.
- [ ] Damage and DEF behavior match documented placeholders or approved values.
- [ ] Combat documentation and balance notes are current.

### Risks

- Prototype combat may hardcode temporary values.
- Enemy AI may become more complex than approved.
- Boss phase behavior may become underdocumented.
- Client UI may appear to determine combat outcomes.
- Balance placeholders may be mistaken for final values.
- Combat implementation may expand beyond MVP validation.

## Milestone 3: Vertical Slice

### Goal

Prove the core MVP experience end-to-end at representative quality.

Vertical Slice should demonstrate how the approved systems work together: player entry, data loading, save state, creature state, combat, rewards, progression, evolution foundation, gene foundation, collection foundation, economy support, world progression, and required UI flow.

### Requirements

- First Playable is complete.
- Combat Prototype is complete.
- Core loop can be experienced end-to-end.
- Required MVP systems are integrated at a representative quality level.
- Data-driven content is used for the slice.
- Save state persists required MVP state.
- UI supports the slice without owning gameplay authority.
- Economy rewards and costs are server-authoritative where included.
- Progression state is server-authoritative.
- Documentation matches implemented behavior.
- Human playtest is performed.

### Deliverables

- End-to-end playable MVP slice.
- Representative creature data.
- Representative skill data.
- Representative world data.
- Representative combat data.
- Representative economy or reward data where included.
- Save/load validation notes.
- UI validation notes.
- Human playtest notes.
- Balance review notes.
- Updated MVP checklist.
- Internal review record.

### Exit Criteria

- [ ] A player can complete the approved vertical slice flow.
- [ ] The slice demonstrates the core loop.
- [ ] Server-owned progression state updates correctly.
- [ ] Required save state persists correctly.
- [ ] Combat functions within approved MVP rules.
- [ ] Reward and economy behavior is server-authoritative where included.
- [ ] Creature state is displayed and updated according to approved rules.
- [ ] Collection state is represented where included.
- [ ] Evolution and gene foundations are represented only as documented.
- [ ] UI supports the flow clearly.
- [ ] No out-of-scope system is introduced.
- [ ] Playtest notes are recorded.
- [ ] Balance risks are recorded.
- [ ] Review approves the slice for content completion work.

### Dependencies

- Milestone 2 completion.
- Save system validation.
- Creature runtime model.
- Economy reward source definition.
- Collection rules definition.
- Evolution requirements definition.
- Gene meaning definition.
- UI flow documentation.
- Balance philosophy approval.
- Content pipeline approval.

### Review Checklist

- [ ] Vertical Slice proves the approved core loop.
- [ ] Systems are integrated without hidden mechanics.
- [ ] Data is driving gameplay-facing values.
- [ ] Server authority is preserved.
- [ ] UI remains separate from gameplay logic.
- [ ] Save state is stable through the slice.
- [ ] Economy behavior is validated where included.
- [ ] Progression behavior is validated.
- [ ] Documentation matches the slice.
- [ ] Playtest feedback is reviewed.

### Risks

- Slice may reveal missing design decisions.
- Integration may expose save or data schema gaps.
- UI flow may be unclear without additional guidance.
- Economy and reward behavior may need stricter balance review.
- Vertical Slice may expand into content production too early.
- Representative content may be mistaken for final content quantity.

## Milestone 4: Content Complete

### Goal

Complete all approved MVP content and supporting configuration required for the MVP release candidate.

Content Complete means required MVP content is authored, integrated, validated, reviewed, and documented. It does not mean new systems may be added.

### Requirements

- Vertical Slice is complete and approved.
- MVP content list is defined through roadmap and task documents.
- Required creature content is complete.
- Required skill content is complete.
- Required world content is complete.
- Required boss content is complete.
- Required economy and reward content is complete.
- Required collection content is complete.
- Required UI content support is complete.
- Required art references are complete or tracked.
- Required audio and visual feedback scope is complete or tracked.
- Required save fields are finalized for MVP.
- Required documentation reflects completed content.

### Deliverables

- Completed approved MVP configuration content.
- Completed required MVP UI flows.
- Completed required save coverage.
- Completed required review records.
- Completed required balance pass notes.
- Completed required content validation notes.
- Updated `docs/MVP_CHECKLIST.md`.
- Updated `docs/CHANGELOG.md` when applicable.
- Updated `docs/KNOWN_ISSUES.md`.
- Release candidate issue list.

### Exit Criteria

- [ ] Approved MVP content list is complete.
- [ ] All required config references validate.
- [ ] No required MVP content is missing.
- [ ] No reserved systems are activated without approval.
- [ ] No hardcoded gameplay values are used where config is required.
- [ ] Save data supports required MVP state.
- [ ] UI supports required MVP flows.
- [ ] Economy values are documented and reviewed.
- [ ] Combat values are documented and reviewed.
- [ ] Balance pass is complete for MVP content.
- [ ] Known issues are reviewed and classified.
- [ ] No blocking content defects remain.
- [ ] Documentation is current.

### Dependencies

- Milestone 3 completion.
- Approved MVP content list.
- Data validation process.
- Config structure approval.
- Art pipeline readiness.
- UI requirements approval.
- Economy and balance review.
- Combat review.
- Save compatibility review.
- Human playtest feedback from Vertical Slice.

### Review Checklist

- [ ] Content matches approved MVP scope.
- [ ] Content quantities match approved task or roadmap records.
- [ ] Config references are valid.
- [ ] Rewards are approved and reviewed.
- [ ] Economy impact is reviewed.
- [ ] Combat impact is reviewed.
- [ ] Progression impact is reviewed.
- [ ] Art references follow the art bible.
- [ ] UI supports content presentation.
- [ ] Known issues are documented.
- [ ] No unapproved mechanics were added during content work.

### Risks

- Content may be added without approval.
- Balance may shift as content quantity increases.
- Art or UI readiness may lag behind gameplay data.
- Save schema changes may appear late.
- Known issues may be misclassified as acceptable.
- Content Complete may be treated as permission for feature expansion.

## Milestone 5: MVP Release

### Goal

Prepare and approve the MVP for release.

MVP Release confirms that the approved MVP is complete, stable, documented, reviewed, playtested, balanced, and ready for release according to the Definition of Done.

### Requirements

- Content Complete is approved.
- All required MVP tasks are complete.
- All required reviews are complete.
- Human playtest is complete.
- Balance pass is complete.
- Security review is complete for relevant systems.
- Performance review is complete for relevant systems.
- Save/load validation is complete.
- Known issues are documented and accepted or resolved.
- Changelog is current.
- Release notes are prepared.
- MVP exit criteria are satisfied.

### Deliverables

- Approved MVP release candidate.
- Final review records.
- Final playtest notes.
- Final balance notes.
- Final known issue list.
- Final MVP checklist status.
- Final changelog update.
- Release notes.
- Release approval record.

### Exit Criteria

- [ ] `docs/MVP_CHECKLIST.md` MVP exit criteria are satisfied.
- [ ] `docs/DEFINITION_OF_DONE.md` requirements are satisfied for all completed work.
- [ ] Required documentation is current.
- [ ] Required reviews are approved.
- [ ] Required playtests are complete.
- [ ] Required balance pass is complete.
- [ ] Required security checks are complete.
- [ ] Required performance checks are complete.
- [ ] Save/load behavior is validated.
- [ ] No critical known issue remains unresolved.
- [ ] No undocumented mechanic exists in the release candidate.
- [ ] No out-of-scope system exists in the release candidate.
- [ ] Release notes are complete.
- [ ] Human project owner approves release.

### Dependencies

- Milestone 4 completion.
- Final internal review.
- Final human playtest.
- Final balance pass.
- Final security review.
- Final performance review.
- Final documentation audit.
- Project owner approval.

### Review Checklist

- [ ] MVP scope is satisfied.
- [ ] MVP scope has not expanded without approval.
- [ ] Core loop is playable.
- [ ] Combat follows approved MVP rules.
- [ ] Progression follows approved MVP rules.
- [ ] Save system safely persists required state.
- [ ] Data-driven configuration is used.
- [ ] Server authority is preserved.
- [ ] UI does not own gameplay authority.
- [ ] Economy and rewards are validated.
- [ ] Known issues are documented.
- [ ] Release notes are accurate.
- [ ] Changelog is current.

### Risks

- Late changes may destabilize the release candidate.
- Known issues may be accepted without clear ownership.
- Balance changes may be rushed.
- Documentation may fall behind final behavior.
- Release pressure may weaken scope control.
- Non-blocking polish may be confused with release blockers.

## Milestone Review Rules

Every milestone must pass review before the next milestone begins.

### Required Review Questions

- [ ] Did the milestone satisfy its goal?
- [ ] Were all requirements met?
- [ ] Were all deliverables produced?
- [ ] Were all exit criteria satisfied?
- [ ] Were dependencies resolved?
- [ ] Were review checklists completed?
- [ ] Were risks recorded?
- [ ] Were blocking issues resolved?
- [ ] Were non-blocking issues documented?
- [ ] Was documentation updated?
- [ ] Was MVP scope protected?

### Review Outputs

Every milestone review must produce:

- Milestone status.
- Summary of completed work.
- Summary of missing work.
- Blocking issues.
- Accepted risks.
- Required follow-up tasks.
- Documentation updates.
- Approval or rejection.

## Scope Control

Milestones do not authorize scope expansion.

If a milestone reveals missing design or missing technical planning, the issue must return to the documented workflow:

1. Idea.
2. Discussion.
3. Design Decision.
4. Documentation.
5. Task Creation.
6. Implementation.
7. Review.

### Scope Control Checklist

- [ ] The work supports MVP goals.
- [ ] The work is approved in documentation.
- [ ] The work is tracked in tasks or checklist records.
- [ ] The work has clear acceptance criteria.
- [ ] The work avoids undocumented mechanics.
- [ ] The work avoids unapproved systems.
- [ ] The work avoids unrelated changes.
- [ ] The work avoids hidden hardcoded values.
- [ ] The work can be reviewed before milestone approval.

## Professional Conclusion

The Project Genesis MVP milestone plan exists to move production from foundation to release through deliberate, reviewable gates.

Each milestone has a specific purpose, clear deliverables, explicit exit criteria, known dependencies, and review expectations.

The MVP is complete only when the approved scope is implemented, documented, validated, reviewed, and accepted.

No milestone may be used to bypass documentation, introduce undocumented mechanics, or expand scope without approval.
