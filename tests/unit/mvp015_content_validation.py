#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CREATURE_DIR = ROOT / "configs" / "creatures"
EVOLUTION_DIR = ROOT / "configs" / "evolutions"

RARITY_COUNTS = {
    "Common": 3,
    "Rare": 4,
    "Epic": 3,
    "Legend": 2,
}


class TokenStream:
    def __init__(self, source: str):
        self.source = source
        self.index = 0

    def peek(self) -> str:
        self._skip_space()
        return self.source[self.index] if self.index < len(self.source) else ""

    def take(self, expected: str | None = None) -> str:
        self._skip_space()
        if self.index >= len(self.source):
            raise AssertionError("Unexpected end of source.")

        char = self.source[self.index]
        if expected is not None and char != expected:
            raise AssertionError(f"Expected {expected!r}, got {char!r}.")

        self.index += 1
        return char

    def take_identifier(self) -> str:
        self._skip_space()
        start = self.index
        while self.index < len(self.source):
            char = self.source[self.index]
            if not (char.isalnum() or char == "_"):
                break
            self.index += 1
        if self.index == start:
            raise AssertionError(f"Expected identifier near {self.source[start:start + 20]!r}.")
        return self.source[start:self.index]

    def take_number(self) -> int:
        self._skip_space()
        start = self.index
        while self.index < len(self.source) and self.source[self.index].isdigit():
            self.index += 1
        if self.index == start:
            raise AssertionError(f"Expected number near {self.source[start:start + 20]!r}.")
        return int(self.source[start:self.index])

    def take_string(self) -> str:
        self.take('"')
        value = []
        while self.index < len(self.source):
            char = self.source[self.index]
            self.index += 1
            if char == '"':
                return "".join(value)
            if char == "\\":
                if self.index >= len(self.source):
                    raise AssertionError("Unterminated escape sequence.")
                value.append(self.source[self.index])
                self.index += 1
            else:
                value.append(char)
        raise AssertionError("Unterminated string.")

    def _skip_space(self) -> None:
        while self.index < len(self.source):
            if self.source.startswith("--", self.index):
                while self.index < len(self.source) and self.source[self.index] != "\n":
                    self.index += 1
                continue
            if self.source[self.index].isspace():
                self.index += 1
                continue
            break


def parse_value(tokens: TokenStream):
    char = tokens.peek()
    if char == "{":
        return parse_table(tokens)
    if char == '"':
        return tokens.take_string()
    if char.isdigit():
        return tokens.take_number()

    ident = tokens.take_identifier()
    if ident == "true":
        return True
    if ident == "false":
        return False
    if ident == "nil":
        return None
    raise AssertionError(f"Unsupported literal {ident!r}.")


def parse_table(tokens: TokenStream):
    tokens.take("{")
    keyed = {}
    array = []

    while True:
        char = tokens.peek()
        if char == "}":
            tokens.take("}")
            break

        if char == '"':
            array.append(parse_value(tokens))
        elif char.isdigit():
            array.append(parse_value(tokens))
        else:
            ident = tokens.take_identifier()
            if tokens.peek() == "=":
                tokens.take("=")
                keyed[ident] = parse_value(tokens)
            else:
                if ident == "true":
                    array.append(True)
                elif ident == "false":
                    array.append(False)
                elif ident == "nil":
                    array.append(None)
                else:
                    array.append(ident)

        if tokens.peek() == ",":
            tokens.take(",")

    if keyed and array:
        keyed["_array"] = array
        return keyed
    if keyed:
        return keyed
    return array


def load_config(path: Path) -> dict:
    source = path.read_text(encoding="utf-8")
    marker = "return"
    start = source.find(marker)
    if start == -1:
        raise AssertionError(f"{path}: missing return table.")
    tokens = TokenStream(source[start + len(marker):])
    value = parse_value(tokens)
    if not isinstance(value, dict):
        raise AssertionError(f"{path}: config did not parse as table.")
    value["_path"] = str(path.relative_to(ROOT))
    return value


def load_configs(folder: Path) -> list[dict]:
    return [load_config(path) for path in sorted(folder.glob("*_config.luau"))]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def validate_creature_shape(creature: dict) -> None:
    for field in (
        "id",
        "creatureId",
        "displayName",
        "rarity",
        "elementType",
        "description",
        "placeholderArtSlot",
        "evolutionLineId",
        "collectionCategory",
        "visualRef",
    ):
        require(isinstance(creature.get(field), str) and creature[field], f"{creature['_path']}: invalid {field}.")

    require(creature["id"] == creature["creatureId"], f"{creature['_path']}: id must match creatureId.")
    require(creature["rarity"] in RARITY_COUNTS, f"{creature['_path']}: invalid rarity.")
    require(isinstance(creature.get("schemaVersion"), int), f"{creature['_path']}: invalid schemaVersion.")
    require(isinstance(creature.get("sortOrder"), int), f"{creature['_path']}: invalid sortOrder.")
    require(isinstance(creature.get("isEnabled"), bool), f"{creature['_path']}: invalid isEnabled.")
    require(isinstance(creature.get("baseStats"), dict), f"{creature['_path']}: invalid baseStats.")
    require(isinstance(creature.get("skillIds"), list), f"{creature['_path']}: invalid skillIds.")
    require(isinstance(creature.get("geneSlots"), list), f"{creature['_path']}: invalid geneSlots.")

    for stat in ("hp", "atk", "def", "spd"):
        require(isinstance(creature["baseStats"].get(stat), int), f"{creature['_path']}: invalid baseStats.{stat}.")
        require(creature["baseStats"][stat] > 0, f"{creature['_path']}: baseStats.{stat} must be positive.")

    metadata = creature.get("cardMetadata")
    require(isinstance(metadata, dict), f"{creature['_path']}: invalid cardMetadata.")
    for field in ("displayName", "rarity", "elementType", "description", "placeholderArtSlot", "evolutionTarget"):
        require(metadata.get(field) == creature.get(field), f"{creature['_path']}: cardMetadata.{field} mismatch.")
    require(metadata.get("stats") == creature["baseStats"], f"{creature['_path']}: cardMetadata.stats mismatch.")


def validate_evolution_shape(evolution: dict) -> None:
    for field in ("id", "evolutionId", "evolutionLineId", "fromCreatureId", "toCreatureId"):
        require(isinstance(evolution.get(field), str) and evolution[field], f"{evolution['_path']}: invalid {field}.")
    require(evolution["id"] == evolution["evolutionId"], f"{evolution['_path']}: id must match evolutionId.")
    require(isinstance(evolution.get("schemaVersion"), int), f"{evolution['_path']}: invalid schemaVersion.")
    require(isinstance(evolution.get("requiredLevel"), int) and evolution["requiredLevel"] > 0, f"{evolution['_path']}: invalid requiredLevel.")
    require(isinstance(evolution.get("biomassCost"), int) and evolution["biomassCost"] >= 0, f"{evolution['_path']}: invalid biomassCost.")
    require(isinstance(evolution.get("isEnabled"), bool), f"{evolution['_path']}: invalid isEnabled.")


def main() -> None:
    creatures = load_configs(CREATURE_DIR)
    evolutions = load_configs(EVOLUTION_DIR)

    require(len(creatures) == 12, f"Expected 12 creature configs, got {len(creatures)}.")
    require(len(evolutions) == 6, f"Expected 6 evolution configs, got {len(evolutions)}.")

    for creature in creatures:
        validate_creature_shape(creature)
    for evolution in evolutions:
        validate_evolution_shape(evolution)

    creature_ids = [creature["creatureId"] for creature in creatures]
    evolution_ids = [evolution["evolutionId"] for evolution in evolutions]
    require(len(creature_ids) == len(set(creature_ids)), "Duplicate creatureId detected.")
    require(len(evolution_ids) == len(set(evolution_ids)), "Duplicate evolutionId detected.")

    enabled_creatures = [creature for creature in creatures if creature["isEnabled"]]
    disabled_creatures = [creature["creatureId"] for creature in creatures if not creature["isEnabled"]]
    require(not disabled_creatures, f"Unexpected disabled creature configs: {disabled_creatures}.")

    counts = {rarity: 0 for rarity in RARITY_COUNTS}
    for creature in enabled_creatures:
        counts[creature["rarity"]] += 1
    require(counts == RARITY_COUNTS, f"Rarity distribution mismatch: expected {RARITY_COUNTS}, got {counts}.")

    creature_by_id = {creature["creatureId"]: creature for creature in creatures}
    evolution_by_from = {evolution["fromCreatureId"]: evolution for evolution in evolutions if evolution["isEnabled"]}

    for evolution in evolutions:
        require(evolution["fromCreatureId"] in creature_by_id, f"{evolution['_path']}: missing fromCreatureId target.")
        require(evolution["toCreatureId"] in creature_by_id, f"{evolution['_path']}: missing toCreatureId target.")
        source = creature_by_id[evolution["fromCreatureId"]]
        target = creature_by_id[evolution["toCreatureId"]]
        require(source["evolutionTarget"] == target["creatureId"], f"{evolution['_path']}: source evolutionTarget mismatch.")
        require(source["evolutionLineId"] == evolution["evolutionLineId"], f"{evolution['_path']}: source evolutionLineId mismatch.")
        require(target["evolutionLineId"] == evolution["evolutionLineId"], f"{evolution['_path']}: target evolutionLineId mismatch.")

    for creature in creatures:
        target = creature.get("evolutionTarget")
        if target is None:
            continue
        require(target in creature_by_id, f"{creature['_path']}: missing evolutionTarget creature.")
        require(creature["creatureId"] in evolution_by_from, f"{creature['_path']}: missing evolution config for evolutionTarget.")
        require(evolution_by_from[creature["creatureId"]]["toCreatureId"] == target, f"{creature['_path']}: evolution config target mismatch.")

    synthetic_disabled = dict(creatures[0])
    synthetic_disabled["isEnabled"] = False
    enabled_with_disabled = [creature for creature in creatures + [synthetic_disabled] if creature["isEnabled"]]
    require(len(enabled_with_disabled) == 12, "Disabled config check failed: disabled records must not count as enabled.")

    print("[MVP-015] Content validation PASS")
    print(f"[MVP-015] Creatures: {len(creatures)} enabled={len(enabled_creatures)} rarity={counts}")
    print(f"[MVP-015] Evolutions: {len(evolutions)}")


if __name__ == "__main__":
    main()
