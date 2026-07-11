export type CreatureSnapshotType = {
	instanceId: string,
	creatureId: string,
	displayName: string,
	-- Strictly presentation fields only. No server-only metadata.
	-- (e.g. no hidden genes, no private loadouts)
}

return {}
