# Project Genesis Security Guide

## Purpose

This document defines the security principles every programmer must follow when working on Project Genesis.

Project Genesis is a Roblox game with a server-authoritative architecture. The server owns all trusted gameplay state, progression state, economy state, combat outcomes, save data, rewards, and validation rules.

This guide is mandatory for:

- AI assistants.
- Human programmers.
- Reviewers.
- Technical designers.
- Data authors who affect gameplay values.
- Any contributor adding or modifying RemoteEvents, RemoteFunctions, save behavior, economy behavior, combat behavior, progression behavior, or player-owned state.

This document contains security policy only.

It does not provide implementation code.

## Status

- Document Status: Active
- Scope: MVP security principles
- Project Type: Roblox
- Architecture: Server-authoritative
- Owner: Technical Architecture
- Last Updated: 2026-06-28

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Security Philosophy](#security-philosophy)
- [Trust Model](#trust-model)
- [Server Responsibilities](#server-responsibilities)
- [Client Responsibilities](#client-responsibilities)
- [RemoteEvent Rules](#remoteevent-rules)
- [RemoteFunction Rules](#remotefunction-rules)
- [Data Validation](#data-validation)
- [Anti Exploit Principles](#anti-exploit-principles)
- [Economy Validation](#economy-validation)
- [Combat Validation](#combat-validation)
- [Save Data Validation](#save-data-validation)
- [Rate Limiting](#rate-limiting)
- [Input Validation](#input-validation)
- [Authority Rules](#authority-rules)
- [Logging Recommendations](#logging-recommendations)
- [Good Practices](#good-practices)
- [Bad Practices](#bad-practices)
- [Security Review Checklist](#security-review-checklist)
- [Professional Conclusion](#professional-conclusion)

## Security Philosophy

Security in Project Genesis is based on one rule:

**The client is never trusted with authoritative gameplay state.**

Roblox clients can be inspected, modified, delayed, replayed, automated, or exploited. Any value sent by a client must be treated as a request, not as truth.

The server must validate every gameplay-relevant action before applying it.

Security exists to protect:

- Player progression.
- Creature ownership.
- Creature stats.
- Combat outcomes.
- Economy balances.
- Inventory contents.
- Save data integrity.
- Collection progress.
- Evolution state.
- Gene state.
- Prestige state.
- World progression.
- Boss and challenge results.
- Player trust.
- Long-term maintainability.

Security must be designed into every system from the beginning.

It must not be treated as cleanup after implementation.

### Core Security Principles

- Never trust client damage.
- Never trust client currency.
- Never trust client progression.
- Never trust client rewards.
- Never trust client inventory state.
- Never trust client creature state.
- Never trust client combat results.
- Never trust client save data.
- Never trust client cooldown state.
- Never trust client eligibility checks.
- Always validate every RemoteEvent.
- Always validate every RemoteFunction.
- Always enforce server authority.
- Always use data-driven validation where applicable.
- Always reject invalid requests safely.
- Always log suspicious patterns when useful.

## Trust Model

The Project Genesis trust model defines which side owns which responsibility.

### Trusted

The server is trusted to:

- Load player data.
- Validate requests.
- Apply gameplay rules.
- Calculate combat results.
- Grant rewards.
- Spend currency.
- Modify inventory.
- Modify creature data.
- Modify progression data.
- Save player state.
- Enforce cooldowns.
- Enforce eligibility.
- Enforce rate limits.
- Reject invalid input.

### Untrusted

The client is untrusted for:

- Damage values.
- Currency values.
- Reward values.
- Inventory contents.
- Creature ownership.
- Creature stats.
- Combat outcomes.
- Skill cooldowns.
- Action gauge state.
- Battle victory.
- Battle defeat.
- Evolution eligibility.
- Collection completion.
- World completion.
- Prestige eligibility.
- Save data.
- Data identifiers without validation.
- Timing claims.
- Any request frequency claims.

### Client Requests

A client request means:

- The player is asking the server to perform an action.
- The server must decide whether the action is valid.
- The server must calculate the result.
- The server must update state if valid.
- The server must reject or ignore the request if invalid.

A client request does not mean:

- The action already happened.
- The reward is owed.
- The player has the required resources.
- The player owns the referenced creature.
- The player passed a requirement.
- The player completed combat.
- The client-provided values are correct.

## Server Responsibilities

The server is responsible for all authoritative game state and all trusted decisions.

### Required Server Responsibilities

- Validate every RemoteEvent request.
- Validate every RemoteFunction request.
- Own player save state.
- Own economy balances.
- Own inventory mutations.
- Own creature ownership.
- Own combat simulation or combat result validation.
- Own progression unlocks.
- Own reward grants.
- Own currency spending.
- Own evolution changes.
- Own gene state changes.
- Own collection state changes.
- Own prestige state changes.
- Enforce cooldowns.
- Enforce rate limits.
- Enforce data schema expectations.
- Reject malformed input.
- Handle missing data safely.
- Record security-relevant warnings where useful.

### Server Must Never

- Accept client-calculated damage as final.
- Accept client-calculated rewards as final.
- Accept client-reported currency balances.
- Accept client-reported inventory contents.
- Accept client-reported creature stats.
- Accept client-reported battle results.
- Accept client-reported progression unlocks.
- Accept client-reported save payloads as authoritative.
- Apply a request before validation.
- Trust a client-provided table without shape validation.
- Trust a client-provided Instance without ownership validation.
- Trust a client-provided identifier without checking server data.

## Client Responsibilities

The client is responsible for presentation, input collection, and displaying server-approved state.

The client may request actions, but it must not decide final gameplay outcomes.

### Allowed Client Responsibilities

- Display UI.
- Display combat state provided by the server.
- Display currency state provided by the server.
- Display inventory state provided by the server.
- Display creature state provided by the server.
- Collect player input.
- Request an action from the server.
- Show loading, success, failure, and error states.
- Play visual effects approved by server state.
- Play audio in response to approved state.
- Predict non-authoritative presentation only when explicitly allowed by architecture.

### Client Must Never

- Grant rewards.
- Grant currency.
- Grant items.
- Grant creatures.
- Modify authoritative progression.
- Modify authoritative save data.
- Decide combat victory.
- Decide combat damage.
- Decide evolution success.
- Decide collection completion.
- Decide prestige eligibility.
- Bypass server validation.
- Hide failed validation as success.
- Treat local state as permanent truth.

### Client Display Rule

The client may display what appears to happen.

The server decides what actually happens.

## RemoteEvent Rules

RemoteEvents are a major security boundary in Roblox.

Every RemoteEvent must be treated as an untrusted public entry point.

### RemoteEvent Requirements

- Every RemoteEvent must have a documented purpose.
- Every RemoteEvent must have a clear owner.
- Every RemoteEvent must have expected parameters documented.
- Every RemoteEvent must validate parameter count.
- Every RemoteEvent must validate parameter types.
- Every RemoteEvent must validate identifier existence.
- Every RemoteEvent must validate ownership.
- Every RemoteEvent must validate eligibility.
- Every RemoteEvent must validate request timing.
- Every RemoteEvent must enforce rate limits when needed.
- Every RemoteEvent must fail safely.
- Every RemoteEvent must avoid exposing internal server state unnecessarily.

### RemoteEvent Must Not

- Accept damage numbers from the client.
- Accept reward amounts from the client.
- Accept currency balances from the client.
- Accept item grants from the client.
- Accept creature stat changes from the client.
- Accept battle completion as truth from the client.
- Accept progression completion as truth from the client.
- Accept arbitrary save data from the client.
- Accept arbitrary module names, service names, or function names.
- Trigger unrelated systems as side effects.

### RemoteEvent Good Example

Good practice:

- Client requests to start an approved action.
- Server checks the player.
- Server checks the target identifier.
- Server checks ownership or eligibility.
- Server checks rate limits.
- Server calculates the result.
- Server updates authoritative state.
- Server sends approved state back to the client.

### RemoteEvent Bad Example

Bad practice:

- Client sends a damage value.
- Server applies the damage value directly.
- Server grants rewards based on the client result.

Reason this is bad:

- The client can forge damage.
- The client can forge combat results.
- The client can farm rewards without valid gameplay.

## RemoteFunction Rules

RemoteFunctions are also security boundaries and must be used carefully.

RemoteFunctions return data to the client and can block while waiting for a response. They must be limited to clear request-response cases and must never expose authority to the client.

### RemoteFunction Requirements

- Every RemoteFunction must have a documented purpose.
- Every RemoteFunction must have clear expected parameters.
- Every RemoteFunction must return only approved data.
- Every RemoteFunction must validate every input.
- Every RemoteFunction must avoid expensive computation per call.
- Every RemoteFunction must enforce rate limits when needed.
- Every RemoteFunction must avoid returning sensitive internal state.
- Every RemoteFunction must handle invalid requests safely.
- Every RemoteFunction must have predictable response behavior.

### RemoteFunction Must Not

- Let the client calculate or confirm final rewards.
- Let the client calculate or confirm final combat results.
- Let the client mutate authoritative state without validation.
- Return entire raw save payloads unless explicitly approved.
- Return server-only configuration that enables exploitation.
- Perform long-running operations triggered by arbitrary client calls.
- Depend on client-provided security decisions.

### RemoteFunction Good Example

Good practice:

- Client asks for a server-approved snapshot of displayable state.
- Server validates the player.
- Server returns only the fields the UI is allowed to show.

### RemoteFunction Bad Example

Bad practice:

- Client sends its local inventory table.
- Server compares it casually and accepts missing or added items.

Reason this is bad:

- The client can forge inventory data.
- The server loses authority over item ownership.
- Save state may become corrupted.

## Data Validation

Every data-driven system must validate data before using it in gameplay.

Data-driven architecture does not mean data is automatically safe.

### Static Data Validation

Static data should be checked for:

- Required fields.
- Correct field types.
- Valid identifiers.
- Valid references.
- Valid enum values.
- Valid numeric ranges when ranges are defined.
- Missing optional fields.
- Duplicate identifiers.
- Incompatible relationships.
- Placeholder values used in active gameplay.

### Runtime Data Validation

Runtime data should be checked for:

- Player ownership.
- Current state.
- Eligibility.
- Cooldown state.
- Resource availability.
- Progression state.
- Battle state.
- Save state consistency.
- Request frequency.
- Request order when order matters.

### Data Validation Good Example

Good practice:

- Server receives a creature identifier.
- Server checks that the identifier exists in approved data.
- Server checks that the player owns that creature.
- Server checks that the creature is eligible for the requested action.
- Server applies the server-approved result.

### Data Validation Bad Example

Bad practice:

- Server receives a creature identifier.
- Server assumes the client owns it.
- Server applies progression or rewards.

Reason this is bad:

- The client can reference another creature.
- The client can reference invalid data.
- The client can bypass progression rules.

## Anti Exploit Principles

Project Genesis must assume that exploit attempts will happen.

The goal is to make exploitation difficult, limited, detectable, and non-authoritative.

### Anti Exploit Rules

- Keep authoritative state on the server.
- Keep reward logic on the server.
- Keep combat outcomes on the server.
- Keep economy mutations on the server.
- Keep save mutations on the server.
- Validate every remote request.
- Rate limit repeated requests.
- Reject impossible requests.
- Reject malformed requests.
- Reject requests that reference unowned state.
- Reject requests that violate current progression.
- Reject requests that occur too frequently.
- Avoid exposing internal tables to the client.
- Avoid trusting client-side cooldowns.
- Avoid trusting client-side timers.
- Avoid trusting client-side battle state.

### Exploit Categories To Consider

- Forged damage.
- Forged rewards.
- Forged currency.
- Forged inventory.
- Forged creature ownership.
- Forged progression.
- Forged battle results.
- Forged cooldown completion.
- Repeated remote spam.
- Invalid identifier injection.
- Oversized payloads.
- Unexpected data types.
- Replay of old requests.
- Request ordering abuse.

### Anti Exploit Review Questions

- What happens if the client sends this request repeatedly?
- What happens if the client sends invalid data?
- What happens if the client sends data for another creature?
- What happens if the client sends data for a locked world?
- What happens if the client sends negative values?
- What happens if the client sends extremely large values?
- What happens if the client skips the intended UI flow?
- What happens if the client calls the RemoteEvent directly?
- What happens if the client sends the request out of order?

## Economy Validation

Economy state is high risk and must be fully server-authoritative.

The client must never be trusted with currency amounts, costs, rewards, balances, or transaction outcomes.

### Economy Authority Rules

- Server owns all currency balances.
- Server owns all currency grants.
- Server owns all currency spending.
- Server owns all reward grants.
- Server owns all item grants.
- Server owns all transaction validation.
- Server owns all affordability checks.
- Server owns all inventory mutations.

### Economy Validation Checklist

- [ ] The player exists and has loaded data.
- [ ] The currency identifier is valid.
- [ ] The transaction type is approved.
- [ ] The cost comes from approved data.
- [ ] The reward comes from approved data.
- [ ] The player can afford the cost.
- [ ] The player is eligible for the transaction.
- [ ] The transaction is applied once.
- [ ] The resulting balance cannot become invalid.
- [ ] The inventory update is server-controlled.
- [ ] The save update is server-controlled.
- [ ] The client receives only the approved result.

### Economy Good Example

Good practice:

- Client requests to perform a purchase.
- Server looks up the item and cost from approved data.
- Server checks the player's server-owned balance.
- Server applies the spend and grant together.
- Server sends the updated approved state to the client.

### Economy Bad Example

Bad practice:

- Client sends current currency balance and purchase cost.
- Server subtracts the client-provided cost.
- Server grants the item.

Reason this is bad:

- The client can forge its balance.
- The client can reduce the cost.
- The client can create invalid transactions.

## Combat Validation

Combat is server-authoritative.

The client may display combat, but it must not determine combat truth.

### Combat Authority Rules

- Server owns battle start validation.
- Server owns creature eligibility.
- Server owns enemy selection validation.
- Server owns battle team validation.
- Server owns combat timing rules.
- Server owns action gauge rules.
- Server owns cooldown rules.
- Server owns damage calculation.
- Server owns DEF reduction behavior.
- Server owns skill usage validation.
- Server owns victory and defeat results.
- Server owns reward eligibility.
- Server owns post-battle healing behavior.

### Combat Validation Checklist

- [ ] The player has loaded data.
- [ ] The battle mode is valid.
- [ ] The selected creature or team is owned by the player.
- [ ] The selected enemy or boss identifier is valid.
- [ ] The selected battle is available to the player.
- [ ] The battle size matches approved rules.
- [ ] Skill identifiers are valid.
- [ ] Cooldown state is server-controlled.
- [ ] Action gauge state is server-controlled.
- [ ] Damage is calculated or validated by the server.
- [ ] Enemy behavior is server-controlled or server-approved.
- [ ] Battle result is determined by the server.
- [ ] Rewards are granted by the server.
- [ ] Creature healing after battle is server-controlled.

### Combat Good Example

Good practice:

- Client requests to start a battle.
- Server validates the selected creature or team.
- Server validates the enemy or boss.
- Server runs or approves the battle according to documented rules.
- Server calculates damage and outcome.
- Server grants rewards only after server-approved completion.

### Combat Bad Example

Bad practice:

- Client sends enemy defeated.
- Client sends damage dealt.
- Client sends reward earned.
- Server accepts all values.

Reason this is bad:

- The client can skip battle.
- The client can forge damage.
- The client can farm rewards.
- The client can corrupt progression.

## Save Data Validation

Save data must be protected from corruption, invalid state, and client forgery.

The server owns save loading, save mutation, and save writing.

### Save Authority Rules

- Server loads save data.
- Server validates save data.
- Server repairs or rejects invalid save fields according to documented policy.
- Server mutates save state through approved systems only.
- Server writes save data.
- Server controls save timing.
- Server controls save structure.
- Server protects against invalid runtime state becoming persisted.

### Save Data Validation Checklist

- [ ] Required save fields exist.
- [ ] Field types are valid.
- [ ] Missing optional fields are handled safely.
- [ ] Currency values are valid.
- [ ] Inventory values are valid.
- [ ] Creature records are valid.
- [ ] Progression records are valid.
- [ ] Collection records are valid.
- [ ] Evolution records are valid.
- [ ] Gene records are valid.
- [ ] Prestige records are valid.
- [ ] Unknown fields are handled according to policy.
- [ ] Invalid references are handled safely.
- [ ] Save writes are not triggered excessively.
- [ ] Save updates are not based on client-provided state.

### Save Data Good Example

Good practice:

- Server loads save data.
- Server validates required fields.
- Server initializes missing approved defaults.
- Server mutates state only through approved services.
- Server writes validated state.

### Save Data Bad Example

Bad practice:

- Client sends a complete save table.
- Server writes it directly.

Reason this is bad:

- The client can grant anything.
- The client can corrupt state.
- The client can bypass every gameplay system.

## Rate Limiting

Rate limiting protects the server from spam, abuse, accidental repeated calls, and exploit attempts.

Rate limits should be applied to RemoteEvents and RemoteFunctions that can be called repeatedly, mutate state, trigger expensive work, or affect rewards.

### Rate Limiting Requirements

- Mutating remotes should be rate limited where appropriate.
- Expensive read remotes should be rate limited where appropriate.
- Repeated invalid requests should be tracked where useful.
- Rate limits should be enforced on the server.
- Rate limits should fail safely.
- Rate limits should not rely on client timers.
- Rate limit behavior should be documented for each remote category.

### Rate Limiting Checklist

- [ ] Can the client call this repeatedly?
- [ ] Can repeated calls grant rewards?
- [ ] Can repeated calls spend or duplicate currency?
- [ ] Can repeated calls create duplicate inventory updates?
- [ ] Can repeated calls start duplicate battles?
- [ ] Can repeated calls trigger excessive save writes?
- [ ] Can repeated calls create excessive server work?
- [ ] Is the limit enforced on the server?
- [ ] Is invalid spam logged or tracked where useful?

### Rate Limiting Good Example

Good practice:

- Server records recent request timing for a mutating action.
- Server rejects repeated requests that occur too quickly.
- Server does not apply rewards or state changes for rejected requests.

### Rate Limiting Bad Example

Bad practice:

- Client disables a button briefly.
- Server assumes the button prevents spam.

Reason this is bad:

- Exploiters can call remotes directly.
- Local UI cooldowns are not security.
- The server remains vulnerable to spam.

## Input Validation

Every client input must be validated before use.

Input validation must happen on the server for gameplay-relevant actions.

### Required Input Checks

- Type check.
- Presence check.
- Identifier check.
- Ownership check.
- Eligibility check.
- Range check when ranges are defined.
- Enum check when enum values are defined.
- Payload size check.
- Table shape check.
- Instance ancestry or ownership check when Instances are accepted.
- Request timing check when timing matters.

### Invalid Input Handling

Invalid input should be handled by:

- Rejecting the request.
- Returning a safe failure response when needed.
- Avoiding state mutation.
- Avoiding reward grants.
- Avoiding save writes.
- Logging suspicious repeated patterns where useful.

Invalid input should not:

- Crash the server.
- Mutate player state.
- Grant rewards.
- Produce partial transactions.
- Expose sensitive internals.
- Create inconsistent UI state.

### Input Validation Good Example

Good practice:

- Server receives an identifier.
- Server checks that it is the expected type.
- Server checks that it exists in approved data.
- Server checks that the player is allowed to use it.
- Server proceeds only after all checks pass.

### Input Validation Bad Example

Bad practice:

- Server receives a table.
- Server assumes it has the expected shape.
- Server reads nested fields directly.

Reason this is bad:

- Missing fields can break behavior.
- Wrong types can cause errors.
- Forged fields can bypass validation.

## Authority Rules

Authority rules define which side is allowed to decide a result.

### Server-Only Authority

The following must always be server-authoritative:

- Player progression.
- World progression.
- Currency balances.
- Currency spending.
- Reward grants.
- Inventory ownership.
- Creature ownership.
- Creature stats.
- Creature level state.
- Evolution state.
- Gene state.
- Collection state.
- Prestige state.
- Combat damage.
- Combat victory.
- Combat defeat.
- Skill cooldowns.
- Action gauge state.
- Boss phase state.
- Save data.

### Client Presentation Authority

The client may control:

- Button visuals.
- Menu navigation.
- Local selection previews.
- Camera presentation.
- Non-authoritative animations.
- Non-authoritative effects.
- Non-authoritative audio.
- Display formatting.
- Temporary loading states.

### Shared Communication Rule

The client may ask.

The server may approve.

The server may reject.

The server decides the final state.

## Logging Recommendations

Logging helps identify mistakes, abuse patterns, and validation problems.

Logging should be useful and controlled. It should not flood output or expose sensitive data.

### Recommended Logging Categories

- Invalid remote parameters.
- Unknown identifiers.
- Ownership validation failures.
- Eligibility validation failures.
- Rate limit violations.
- Impossible combat requests.
- Invalid economy requests.
- Invalid save data fields.
- Repeated malformed requests.
- Unexpected missing static data.
- Server-side validation failures.

### Logging Guidelines

- Log enough context to debug the issue.
- Include the player identifier where appropriate.
- Include the remote or system name where appropriate.
- Include the rejected reason where appropriate.
- Avoid logging full save payloads.
- Avoid logging sensitive internal state unnecessarily.
- Avoid logging every normal failure if it creates noise.
- Rate limit repeated warning logs where appropriate.

### Logging Good Example

Good practice:

- Log that a player attempted an invalid purchase identifier.
- Include the player, request type, and rejected identifier.
- Do not mutate economy state.

### Logging Bad Example

Bad practice:

- Print full player save data every time validation fails.

Reason this is bad:

- It creates noise.
- It may expose unnecessary data.
- It makes real issues harder to identify.

## Good Practices

### Good Practice: Server-Calculated Damage

The client requests combat participation.

The server validates the battle state, selected creature or team, enemy data, action timing, skill availability, and approved formulas.

The server calculates damage and determines the result.

Why this is good:

- Client damage is not trusted.
- Combat remains consistent.
- Rewards depend on server-approved results.

### Good Practice: Server-Owned Currency

The client requests a purchase.

The server reads the cost from approved data and checks the player's server-owned balance.

The server performs the transaction only if all checks pass.

Why this is good:

- Client currency is not trusted.
- Costs cannot be forged by the client.
- Invalid purchases are rejected safely.

### Good Practice: Server-Validated Progression

The client requests to enter or complete progression-related content.

The server checks the player's saved progression state and the approved data requirements.

The server updates progression only after valid completion.

Why this is good:

- Client progression claims are not trusted.
- Progression cannot be skipped through forged remotes.
- Save state remains consistent.

### Good Practice: Documented Remote Ownership

Every remote has a documented purpose, expected inputs, owner, validation rules, and failure behavior.

Why this is good:

- Reviewers can verify authority boundaries.
- AI assistants have clear implementation constraints.
- Undocumented remote behavior is avoided.

## Bad Practices

### Bad Practice: Client Damage

The client tells the server how much damage was dealt.

The server applies that damage directly.

Why this is bad:

- The value can be forged.
- Combat balance can be bypassed.
- Rewards can be exploited.

### Bad Practice: Client Currency

The client tells the server its current currency balance.

The server accepts the value and saves it.

Why this is bad:

- The balance can be forged.
- Economy integrity is destroyed.
- Save data becomes untrusted.

### Bad Practice: Client Progression

The client tells the server that a world, battle, collection, or progression step is complete.

The server accepts the claim without validation.

Why this is bad:

- Progression can be skipped.
- Rewards can be duplicated.
- Player state can become inconsistent.

### Bad Practice: UI Cooldown As Security

The client disables a button after use and the server performs no rate limiting.

Why this is bad:

- Exploiters can call the remote directly.
- The UI does not protect the server.
- Repeated requests can still mutate state.

### Bad Practice: Raw Save Upload

The client sends a save table to the server.

The server writes the table directly.

Why this is bad:

- Every gameplay system can be bypassed.
- Invalid data can be persisted.
- Recovery becomes difficult.

### Bad Practice: Unvalidated Identifier

The client sends an identifier for a creature, skill, item, world, or reward.

The server uses it without checking that it exists and belongs to the player where required.

Why this is bad:

- Invalid data can be referenced.
- Ownership can be bypassed.
- Errors or exploits can occur.

## Security Review Checklist

Every security-relevant task must be reviewed against this checklist.

### General Security Checklist

- [ ] The server remains authoritative.
- [ ] The client does not decide gameplay outcomes.
- [ ] Every RemoteEvent is validated.
- [ ] Every RemoteFunction is validated.
- [ ] Inputs are type checked.
- [ ] Identifiers are checked against approved data.
- [ ] Ownership is validated.
- [ ] Eligibility is validated.
- [ ] Economy state is server-owned.
- [ ] Combat state is server-owned.
- [ ] Save state is server-owned.
- [ ] Rewards are server-granted.
- [ ] Currency is server-mutated.
- [ ] Inventory is server-mutated.
- [ ] Progression is server-mutated.
- [ ] Rate limits are considered.
- [ ] Invalid requests fail safely.
- [ ] Suspicious patterns are logged where useful.
- [ ] Documentation reflects authority boundaries.

### Remote Review Checklist

- [ ] Remote purpose is documented.
- [ ] Remote owner is documented.
- [ ] Expected inputs are documented.
- [ ] Valid outputs or responses are documented.
- [ ] Invalid input behavior is documented.
- [ ] Rate limit expectations are documented.
- [ ] Authority owner is documented.
- [ ] Security risks are documented.

### Economy Review Checklist

- [ ] Client cannot create currency.
- [ ] Client cannot reduce costs.
- [ ] Client cannot grant rewards.
- [ ] Client cannot duplicate inventory.
- [ ] Server validates affordability.
- [ ] Server applies transaction atomically where applicable.
- [ ] Server saves only validated results.

### Combat Review Checklist

- [ ] Client cannot decide damage.
- [ ] Client cannot decide victory.
- [ ] Client cannot decide rewards.
- [ ] Server validates battle eligibility.
- [ ] Server validates creature or team ownership.
- [ ] Server validates enemy or boss identifiers.
- [ ] Server controls cooldown and action gauge state.
- [ ] Server controls post-battle state changes.

### Save Review Checklist

- [ ] Client cannot upload authoritative save data.
- [ ] Server validates loaded save data.
- [ ] Server validates state before saving.
- [ ] Save mutations happen through approved systems.
- [ ] Invalid data is rejected or handled safely.
- [ ] Save writes are not spammed by client requests.

## Professional Conclusion

Project Genesis security is built on server authority, strict validation, documented remotes, and controlled state mutation.

The client is a presentation and input layer. It is not a source of gameplay truth.

Every programmer must assume that client requests can be forged, repeated, malformed, delayed, or sent out of order.

Every gameplay-relevant request must be validated on the server before it changes state.

If a system cannot explain where authority lives, how inputs are validated, and how invalid requests fail safely, it is not ready for implementation or merge.
