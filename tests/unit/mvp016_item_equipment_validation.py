#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ITEM_DIR = ROOT / "configs" / "items"
EQUIPMENT_DIR = ROOT / "configs" / "equipment"
SRC = ROOT / "src"

VALID_ITEM_TYPES = {"equipment", "consumable", "material"}
VALID_RARITIES = {"Common", "Rare", "Epic", "Legend"}
VALID_SLOTS = {"weapon", "armor", "accessory"}


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


def validate_item_shape(item: dict) -> None:
    for field in ("id", "itemId", "displayName", "description", "itemType", "rarity", "iconSlot"):
        require(isinstance(item.get(field), str) and item[field], f"{item['_path']}: invalid {field}.")
    require(item["id"] == item["itemId"], f"{item['_path']}: id must match itemId.")
    require(item["itemType"] in VALID_ITEM_TYPES, f"{item['_path']}: invalid itemType.")
    require(item["rarity"] in VALID_RARITIES, f"{item['_path']}: invalid rarity.")
    require(isinstance(item.get("schemaVersion"), int), f"{item['_path']}: invalid schemaVersion.")
    require(isinstance(item.get("maxStack"), int) and item["maxStack"] > 0, f"{item['_path']}: invalid maxStack.")
    require(isinstance(item.get("sortOrder"), int), f"{item['_path']}: invalid sortOrder.")
    require(isinstance(item.get("tags"), list), f"{item['_path']}: invalid tags.")
    require(isinstance(item.get("isEnabled"), bool), f"{item['_path']}: invalid isEnabled.")
    if item["itemType"] == "equipment":
        require(isinstance(item.get("equipmentId"), str) and item["equipmentId"], f"{item['_path']}: equipment item missing equipmentId.")
        require(item["maxStack"] == 1, f"{item['_path']}: equipment maxStack must be 1.")
    else:
        require(item.get("equipmentId") is None, f"{item['_path']}: non-equipment item must not define equipmentId.")


def validate_equipment_shape(equipment: dict) -> None:
    for field in ("id", "equipmentId", "itemId", "displayName", "slotId", "equipmentType"):
        require(isinstance(equipment.get(field), str) and equipment[field], f"{equipment['_path']}: invalid {field}.")
    require(equipment["id"] == equipment["equipmentId"], f"{equipment['_path']}: id must match equipmentId.")
    require(equipment["slotId"] in VALID_SLOTS, f"{equipment['_path']}: invalid slotId.")
    require(equipment["equipmentType"] == equipment["slotId"], f"{equipment['_path']}: equipmentType must match slotId.")
    require(isinstance(equipment.get("schemaVersion"), int), f"{equipment['_path']}: invalid schemaVersion.")
    require(isinstance(equipment.get("isEnabled"), bool), f"{equipment['_path']}: invalid isEnabled.")
    require(isinstance(equipment.get("statBonuses"), dict), f"{equipment['_path']}: invalid statBonuses.")
    for stat in ("hp", "atk", "def", "spd"):
        value = equipment["statBonuses"].get(stat)
        require(isinstance(value, int) and value >= 0, f"{equipment['_path']}: invalid statBonuses.{stat}.")


def main() -> None:
    items = load_configs(ITEM_DIR)
    equipment_records = load_configs(EQUIPMENT_DIR)

    require(len(items) >= 5, f"Expected at least 5 item configs, got {len(items)}.")
    require(len(equipment_records) >= 4, f"Expected at least 4 equipment configs, got {len(equipment_records)}.")

    for item in items:
        validate_item_shape(item)
    for equipment in equipment_records:
        validate_equipment_shape(equipment)

    item_ids = [item["itemId"] for item in items]
    equipment_ids = [equipment["equipmentId"] for equipment in equipment_records]
    require(len(item_ids) == len(set(item_ids)), "Duplicate itemId detected.")
    require(len(equipment_ids) == len(set(equipment_ids)), "Duplicate equipmentId detected.")

    item_by_id = {item["itemId"]: item for item in items}
    equipment_by_id = {equipment["equipmentId"]: equipment for equipment in equipment_records}
    equipment_by_item = {equipment["itemId"]: equipment for equipment in equipment_records}

    for item in items:
        if item["itemType"] != "equipment":
            continue
        equipment = equipment_by_id.get(item["equipmentId"])
        require(equipment is not None, f"{item['_path']}: missing equipment target.")
        require(equipment["itemId"] == item["itemId"], f"{item['_path']}: equipment itemId mismatch.")
        if item["isEnabled"]:
            require(equipment["isEnabled"], f"{item['_path']}: enabled item points to disabled equipment.")

    for equipment in equipment_records:
        item = item_by_id.get(equipment["itemId"])
        require(item is not None, f"{equipment['_path']}: missing item target.")
        require(item["itemType"] == "equipment", f"{equipment['_path']}: target item is not equipment.")
        if equipment["isEnabled"]:
            require(item["isEnabled"], f"{equipment['_path']}: enabled equipment points to disabled item.")
            require(equipment["itemId"] in equipment_by_item, f"{equipment['_path']}: missing equipment item index.")

    enabled_items = [item for item in items if item["isEnabled"]]
    disabled_items = [item for item in items if not item["isEnabled"]]
    enabled_equipment = [equipment for equipment in equipment_records if equipment["isEnabled"]]
    disabled_equipment = [equipment for equipment in equipment_records if not equipment["isEnabled"]]
    require(disabled_items, "Expected at least one disabled item config for validation.")
    require(disabled_equipment, "Expected at least one disabled equipment config for validation.")
    require({equipment["slotId"] for equipment in enabled_equipment} == VALID_SLOTS, "Enabled equipment must cover every slot.")

    item_service = (SRC / "server" / "services" / "ItemService.luau").read_text(encoding="utf-8")
    equipment_service = (SRC / "server" / "services" / "EquipmentService.luau").read_text(encoding="utf-8")
    slot_schema = (SRC / "shared" / "data" / "EquipmentSlotSchema.luau").read_text(encoding="utf-8")
    require("inventoryState" in item_service, "ItemService must migrate inventoryState.")
    require("equipmentState" in equipment_service, "EquipmentService must migrate equipmentState.")
    require("invalid_quantity" in item_service, "ItemService must reject invalid quantity.")
    for item_id in ("item_training_blade", "item_scout_vest", "item_health_cell"):
        require(item_id in item_service, f"ItemService migration missing {item_id}.")
    for code in (
        "invalid_item",
        "wrong_equipment_type",
        "duplicate_equip",
        "removed_item",
        "disabled_item",
    ):
        require(code in equipment_service, f"EquipmentService missing validation code {code}.")
    require("invalid_slot" in slot_schema, "EquipmentSlotSchema missing validation code invalid_slot.")
    require("unowned_item" in item_service, "ItemService missing validation code unowned_item.")

    print("[MVP-016] Offline validation PASS")
    print(f"[MVP-016] Items: {len(items)} enabled={len(enabled_items)} disabled={len(disabled_items)}")
    print(f"[MVP-016] Equipment: {len(equipment_records)} enabled={len(enabled_equipment)} disabled={len(disabled_equipment)}")
    print("[MVP-016] Slots:", sorted(VALID_SLOTS))


if __name__ == "__main__":
    main()
