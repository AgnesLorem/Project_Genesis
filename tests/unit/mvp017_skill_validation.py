#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SKILL_DIR = ROOT / "configs" / "skills"
CREATURE_DIR = ROOT / "configs" / "creatures"
SRC = ROOT / "src"

VALID_RARITIES = {"Common", "Rare", "Epic", "Legend"}
VALID_SKILL_TYPES = {"active", "passive"}
VALID_TARGET_RULES = {"first_living_enemy", "self"}


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

    def take_number(self) -> int | float:
        self._skip_space()
        start = self.index
        saw_dot = False
        while self.index < len(self.source):
            char = self.source[self.index]
            if char == "." and not saw_dot:
                saw_dot = True
                self.index += 1
                continue
            if not char.isdigit():
                break
            self.index += 1
        if self.index == start:
            raise AssertionError(f"Expected number near {self.source[start:start + 20]!r}.")
        text = self.source[start:self.index]
        return float(text) if "." in text else int(text)

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

        if char == '"' or char.isdigit():
            array.append(parse_value(tokens))
        else:
            ident = tokens.take_identifier()
            if tokens.peek() == "=":
                tokens.take("=")
                keyed[ident] = parse_value(tokens)
            elif ident == "true":
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
    return keyed if keyed else array


def load_config(path: Path) -> dict:
    source = path.read_text(encoding="utf-8")
    start = source.find("return")
    if start == -1:
        raise AssertionError(f"{path}: missing return table.")
    value = parse_value(TokenStream(source[start + len("return"):]))
    if not isinstance(value, dict):
        raise AssertionError(f"{path}: config did not parse as table.")
    value["_path"] = str(path.relative_to(ROOT))
    return value


def load_configs(folder: Path) -> list[dict]:
    return [load_config(path) for path in sorted(folder.glob("*_config.luau"))]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def validate_skill_shape(skill: dict) -> None:
    for field in (
        "id",
        "skillId",
        "displayName",
        "description",
        "skillType",
        "rarity",
        "elementType",
        "targetRule",
        "iconPlaceholder",
    ):
        require(isinstance(skill.get(field), str) and skill[field], f"{skill['_path']}: invalid {field}.")
    require(skill["id"] == skill["skillId"], f"{skill['_path']}: id must match skillId.")
    require(skill["skillType"] in VALID_SKILL_TYPES, f"{skill['_path']}: invalid skillType.")
    require(skill["rarity"] in VALID_RARITIES, f"{skill['_path']}: invalid rarity.")
    require(skill["targetRule"] in VALID_TARGET_RULES, f"{skill['_path']}: invalid targetRule.")
    require(isinstance(skill.get("schemaVersion"), int), f"{skill['_path']}: invalid schemaVersion.")
    require(isinstance(skill.get("cooldown"), int) and skill["cooldown"] >= 0, f"{skill['_path']}: invalid cooldown.")
    require(isinstance(skill.get("damageMultiplier"), (int, float)) and skill["damageMultiplier"] >= 0, f"{skill['_path']}: invalid damageMultiplier.")
    require(isinstance(skill.get("statusEffectRefs"), list), f"{skill['_path']}: invalid statusEffectRefs.")
    require(isinstance(skill.get("isEnabled"), bool), f"{skill['_path']}: invalid isEnabled.")


def main() -> None:
    skills = load_configs(SKILL_DIR)
    creatures = load_configs(CREATURE_DIR)

    require(len(skills) >= 5, f"Expected at least 5 skill configs, got {len(skills)}.")
    for skill in skills:
        validate_skill_shape(skill)

    skill_ids = [skill["skillId"] for skill in skills]
    require(len(skill_ids) == len(set(skill_ids)), "Duplicate skillId detected.")

    enabled_skills = {skill["skillId"]: skill for skill in skills if skill["isEnabled"]}
    disabled_skills = {skill["skillId"]: skill for skill in skills if not skill["isEnabled"]}
    require("basic_attack" in enabled_skills, "basic_attack must be enabled.")
    require("verdant_slash" in enabled_skills, "verdant_slash must be enabled.")
    require("root_guard_passive" in enabled_skills, "root_guard_passive must be enabled.")
    require("shadow_bolt" in enabled_skills, "shadow_bolt must be enabled for unowned validation.")
    require("disabled_skill" in disabled_skills, "disabled_skill config must exist for disabled validation.")
    require(any(skill["skillType"] == "active" for skill in enabled_skills.values()), "Expected at least one active skill.")
    require(any(skill["skillType"] == "passive" for skill in enabled_skills.values()), "Expected at least one passive skill.")

    for creature in creatures:
        for skill_id in creature.get("skillIds", []):
            require(skill_id in enabled_skills, f"{creature['_path']}: missing or disabled skill ref {skill_id}.")

    for starter_id in ("starter_001", "starter_002", "starter_003"):
        starter = next(creature for creature in creatures if creature["creatureId"] == starter_id)
        require("verdant_slash" in starter["skillIds"], f"{starter['_path']}: missing verdant_slash.")
        require("root_guard_passive" in starter["skillIds"], f"{starter['_path']}: missing root_guard_passive.")

    schema = (SRC / "shared" / "data" / "SkillSchema.luau").read_text(encoding="utf-8")
    registry = (SRC / "server" / "data" / "SkillRegistry.luau").read_text(encoding="utf-8")
    service = (SRC / "server" / "services" / "SkillService.luau").read_text(encoding="utf-8")
    battle = (SRC / "server" / "combat" / "BattleSession.luau").read_text(encoding="utf-8")
    remotes = (SRC / "server" / "networking" / "RemoteHandlers.luau").read_text(encoding="utf-8")
    network = (SRC / "client" / "controllers" / "NetworkController.luau").read_text(encoding="utf-8")
    simulator = (SRC / "client" / "controllers" / "GameplaySimulator.luau").read_text(encoding="utf-8")

    for token in ("skillType", "cooldown", "damageMultiplier", "statusEffectRefs", "iconPlaceholder"):
        require(token in schema, f"SkillSchema missing {token}.")
    require("getEnabledSkill" in registry, "SkillRegistry must distinguish enabled skills.")
    for code in ("invalid_skill", "unowned_skill", "disabled_skill", "skill_on_cooldown", "invalid_target", "passive_skill"):
        require(code in service, f"SkillService missing validation code {code}.")
    require("skillState" in service, "SkillService must persist skillState.")
    require("damageMultiplier" in battle and "skillType" in battle and "cooldown" in battle, "BattleSession must use MVP-017 skill fields.")
    for remote_name in ("GetSkillSnapshot", "RequestSkillUse"):
        require(remote_name in remotes, f"RemoteHandlers missing {remote_name}.")
        require(remote_name in network, f"NetworkController missing {remote_name}.")
    for fn in ("runSkillSuite", "runSkillValidationSuite", "runSkillCombatSuite", "runMVP017"):
        require(fn in simulator, f"GameplaySimulator missing {fn}.")

    print("[MVP-017] Skill validation PASS")
    print(f"[MVP-017] Skills: {len(skills)} enabled={len(enabled_skills)} disabled={len(disabled_skills)}")
    print("[MVP-017] Active/passive configs and creature refs valid")


if __name__ == "__main__":
    main()
