# MVP-HARD Tower Challenge Manual QA

Scope: isolated Tower / Challenge Mode only. Do not touch collection, creature inventory, creature detail, or creature card UI.

1. Start Play Solo.
2. Open Output and the in-game developer console.
3. Run `GameplaySimulator.runMvpHardFullFlow()` from the client command bar.
4. Confirm Tower Challenge screen, combat HP updates, Tower result modal, persistence after reconnect, invalid request rejection, spam start rejection, spam completion idempotency, and reconnect-during-run abandonment.
5. Stop on the first Critical or High bug.
