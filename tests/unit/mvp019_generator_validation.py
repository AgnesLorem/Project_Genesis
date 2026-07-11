#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
GENERATOR_DIR = ROOT / "configs" / "generators"
ECONOMY_DIR = ROOT / "configs" / "economy"
SRC = ROOT / "src"

REQUIRED_GENERATORS = {
    "bio_generator",
    "dna_generator",
    "advanced_bio_generator",
}
VALID_UNLOCK_TYPES = {"always", "currencyBalance", "generatorLevel"}


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
        while self.index < len(self.source) and (self.source[self.index].isdigit() or self.source[self.index] == "."):
            self.index += 1
        if self.index == start:
            raise AssertionError(f"Expected number near {self.source[start:start + 20]!r}.")
        val_str = self.source[start:self.index]
        if "." in val_str:
            return float(val_str)
        return int(val_str)

    def take_string(self) -> str:
        self.take('"')
        value: list[str] = []
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


def validate_generator(generator: dict) -> None:
    for field in ("id", "generatorId", "displayName", "currencyType"):
        require(isinstance(generator.get(field), str) and generator[field], f"{generator['_path']}: invalid {field}.")
    require(generator["id"] == generator["generatorId"], f"{generator['_path']}: id must match generatorId.")
    require(isinstance(generator.get("schemaVersion"), int), f"{generator['_path']}: invalid schemaVersion.")
    require(isinstance(generator.get("sortOrder"), int), f"{generator['_path']}: invalid sortOrder.")
    require(isinstance(generator.get("baseRate"), int) and generator["baseRate"] > 0, f"{generator['_path']}: invalid baseRate.")
    require(isinstance(generator.get("capacity"), int) and generator["capacity"] > 0, f"{generator['_path']}: invalid capacity.")
    require(isinstance(generator.get("maxLevel"), int) and generator["maxLevel"] > 0, f"{generator['_path']}: invalid maxLevel.")
    require(isinstance(generator.get("isEnabled"), bool), f"{generator['_path']}: invalid isEnabled.")

    cost = generator.get("upgradeCost")
    require(isinstance(cost, dict), f"{generator['_path']}: upgradeCost must be a table.")
    require(isinstance(cost.get("currencyType"), str) and cost["currencyType"], f"{generator['_path']}: invalid upgradeCost.currencyType.")
    require(isinstance(cost.get("amount"), int) and cost["amount"] > 0, f"{generator['_path']}: invalid upgradeCost.amount.")

    requirement = generator.get("unlockRequirement")
    require(isinstance(requirement, dict), f"{generator['_path']}: unlockRequirement must be a table.")
    require(requirement.get("type") in VALID_UNLOCK_TYPES, f"{generator['_path']}: invalid unlockRequirement.type.")
    if requirement["type"] == "currencyBalance":
        require(isinstance(requirement.get("currencyType"), str) and requirement["currencyType"], f"{generator['_path']}: currency unlock missing currencyType.")
        require(isinstance(requirement.get("amount"), int) and requirement["amount"] > 0, f"{generator['_path']}: currency unlock missing amount.")
    if requirement["type"] == "generatorLevel":
        require(isinstance(requirement.get("generatorId"), str) and requirement["generatorId"], f"{generator['_path']}: generator unlock missing generatorId.")
        require(isinstance(requirement.get("level"), int) and requirement["level"] > 0, f"{generator['_path']}: generator unlock missing level.")


def main() -> None:
    generators = load_configs(GENERATOR_DIR)
    economy = load_configs(ECONOMY_DIR)

    require(len(generators) >= 4, f"Expected at least 4 generator configs, got {len(generators)}.")
    for generator in generators:
        validate_generator(generator)

    ids = [generator["generatorId"] for generator in generators]
    require(len(ids) == len(set(ids)), "Duplicate generatorId detected.")
    by_id = {generator["generatorId"]: generator for generator in generators}
    require(REQUIRED_GENERATORS.issubset(by_id), f"Missing required generators: {sorted(REQUIRED_GENERATORS - set(by_id))}.")
    require(any(not generator["isEnabled"] for generator in generators), "Expected one disabled generator config.")

    enabled = [generator for generator in generators if generator["isEnabled"]]
    disabled = [generator for generator in generators if not generator["isEnabled"]]
    require(by_id["advanced_bio_generator"]["unlockRequirement"]["type"] == "generatorLevel", "advanced_bio_generator must be locked by generator level.")

    valid_currencies = {record["currencyId"] for record in economy}
    for generator in generators:
        require(generator["currencyType"] in valid_currencies, f"{generator['_path']}: unknown currencyType.")
        require(generator["upgradeCost"]["currencyType"] in valid_currencies, f"{generator['_path']}: unknown upgrade currencyType.")
        requirement = generator["unlockRequirement"]
        if requirement["type"] == "currencyBalance":
            require(requirement["currencyType"] in valid_currencies, f"{generator['_path']}: unknown unlock currencyType.")
        if requirement["type"] == "generatorLevel":
            require(requirement["generatorId"] in by_id, f"{generator['_path']}: missing unlock generator target.")

    economy_by_id = {record["currencyId"]: record for record in economy}
    for currency_id in ("biomass", "dna"):
        require("generator_claim" in economy_by_id[currency_id]["sourceRefs"], f"{currency_id}: missing generator_claim sourceRef.")
        require("generator_upgrade" in economy_by_id[currency_id]["sinkRefs"], f"{currency_id}: missing generator_upgrade sinkRef.")

    service = (SRC / "server" / "services" / "GeneratorService.luau").read_text(encoding="utf-8")
    remote_handlers = (SRC / "server" / "networking" / "RemoteHandlers.luau").read_text(encoding="utf-8")
    network_controller = (SRC / "client" / "controllers" / "NetworkController.luau").read_text(encoding="utf-8")
    simulator = (SRC / "client" / "controllers" / "GameplaySimulator.luau").read_text(encoding="utf-8")

    for token in (
        "tryClaim",
        "tryUpgrade",
        "getSnapshotResult",
        "generator_locked",
        "generator_disabled",
        "claim_rate_limited",
        "upgrade_rate_limited",
        "bio_generator_01",
    ):
        require(token in service, f"GeneratorService missing {token}.")
    for remote in ("GetGeneratorSnapshot", "RequestClaimGenerator", "RequestUpgradeGenerator"):
        require(remote in remote_handlers, f"RemoteHandlers missing {remote}.")
        require(remote in network_controller, f"NetworkController missing {remote}.")
    for fn in ("runGeneratorSuite", "runGeneratorValidationSuite", "runGeneratorPersistenceSuite", "runMVP019"):
        require(fn in simulator, f"GameplaySimulator missing {fn}.")

    require((SRC / "client" / "views" / "GeneratorPanel.luau").exists(), "GeneratorPanel missing.")
    require((SRC / "client" / "controllers" / "GeneratorController.luau").exists(), "GeneratorController missing.")

    print("[MVP-019] Generator validation PASS")
    print(f"[MVP-019] Generators: {len(generators)} enabled={len(enabled)} disabled={len(disabled)}")
    print("[MVP-019] Required remotes, simulator suites, unlocks, and economy refs valid")


if __name__ == "__main__":
    main()
