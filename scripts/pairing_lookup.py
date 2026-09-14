#!/usr/bin/env python3
"""Query canonical Go.Breeding pairing groups, commissions, and research records."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
PROGRESS_PATH = ROOT / "data" / "breeding_script_progress.json"
RECORDS_PATH = ROOT / "data" / "pairing_production_records.json"


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def normalized(value: Any) -> str:
    return (
        str(value)
        .strip()
        .lower()
        .replace(" × ", "+")
        .replace(" + ", "+")
    )


class PairingCatalog:
    def __init__(self) -> None:
        self.data: dict[str, Any] = load_json(PROGRESS_PATH)
        self.records: list[dict[str, Any]] = load_json(RECORDS_PATH)
        self.body_types = self.data["body_types"]
        self.body_by_id = {body["id"]: body for body in self.body_types}
        self.groups = self.data["pairing_groups"]
        self.archetypes = self.data["archetypes"]
        self.couplings = self.data["couplings"]

    def resolve_group(self, board_or_group: str) -> tuple[str, dict[str, Any]]:
        query = normalized(board_or_group)
        for board_id, group in self.groups.items():
            if query in {normalized(board_id), normalized(group["key"]), normalized(group["name"])}:
                return board_id, group
        raise KeyError(f"Unknown pairing group: {board_or_group}")

    def resolve_body(self, role: str, body_or_name: str) -> str:
        query = normalized(body_or_name)
        if query in self.body_by_id:
            return query
        for body_id, archetype in self.archetypes[role].items():
            if normalized(archetype["name"]) == query:
                return body_id
        raise KeyError(f"Unknown {role} body/archetype: {body_or_name}")

    def body_index(self, body_id: str) -> int:
        return next(index for index, body in enumerate(self.body_types) if body["id"] == body_id)

    def lookup(self, board_or_group: str, first_body_or_name: str, second_body_or_name: str) -> dict[str, Any]:
        board_id, group = self.resolve_group(board_or_group)
        first_id = self.resolve_body(group["row_role"], first_body_or_name)
        second_id = self.resolve_body(group["column_role"], second_body_or_name)
        first_body = self.body_by_id[first_id]
        second_body = self.body_by_id[second_id]
        first_type = self.archetypes[group["row_role"]][first_id]
        second_type = self.archetypes[group["column_role"]][second_id]
        body_pair = f"{first_id}>{second_id}"
        display_name = f"{first_type['name']} + {second_type['name']}"
        if board_id == "jack_jill":
            coupling = self.couplings.get(body_pair, {"name": display_name, "description": ""})
        else:
            coupling = {
                "name": f"{first_type['name']} & {second_type['name']}",
                "description": (
                    f"{group['name']} choreography commission: "
                    f"{first_body['size']} {first_body['morph']} paired with "
                    f"{second_body['size']} {second_body['morph']}. "
                    "Its bespoke movement theme is still awaiting design."
                ),
            }
        return {
            "commission_key": f"{board_id}|{body_pair}",
            "board_id": board_id,
            "group_key": group["key"],
            "group_name": group["name"],
            "pairing_name": display_name,
            "pairing_slug": normalized(display_name),
            "pairing_type_key": body_pair,
            "pairing_type": f"{first_body['size']} {first_body['morph']} → {second_body['size']} {second_body['morph']}",
            "size_pair": f"{first_body['size'].lower()}>{second_body['size'].lower()}",
            "morph_pair": f"{first_body['morph'].lower()}>{second_body['morph'].lower()}",
            "order": "Regular" if self.body_index(first_id) <= self.body_index(second_id) else "Inverted",
            "coupling_name": coupling["name"],
            "coupling_description": coupling["description"],
            "first": {
                "role": group["row_role"],
                "body_id": first_id,
                "archetype": first_type["name"],
                "emoji": first_type["emoji"],
                "size": first_body["size"],
                "morph": first_body["morph"],
            },
            "second": {
                "role": group["column_role"],
                "body_id": second_id,
                "archetype": second_type["name"],
                "emoji": second_type["emoji"],
                "size": second_body["size"],
                "morph": second_body["morph"],
            },
        }

    def all_lookups(self, board_or_group: str | None = None) -> Iterable[dict[str, Any]]:
        group_ids = [self.resolve_group(board_or_group)[0]] if board_or_group else self.groups.keys()
        for board_id in group_ids:
            for first in self.body_types:
                for second in self.body_types:
                    yield self.lookup(board_id, first["id"], second["id"])

    def search(self, query: str, board_or_group: str | None = None) -> list[dict[str, Any]]:
        needle = normalized(query)
        fields = (
            "commission_key",
            "group_key",
            "group_name",
            "pairing_name",
            "pairing_slug",
            "pairing_type_key",
            "pairing_type",
            "size_pair",
            "morph_pair",
            "coupling_name",
        )
        return [
            item
            for item in self.all_lookups(board_or_group)
            if any(needle in normalized(item[field]) for field in fields)
        ]

    def production_record(self, record_id: str) -> dict[str, Any]:
        for record in self.records:
            if record["record_id"] == record_id:
                return record
        raise KeyError(f"Unknown production record: {record_id}")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--group", help="Board ID or m+f, m+m, f+f group key")
    result.add_argument("--first", help="First body ID or role-aware archetype name")
    result.add_argument("--second", help="Second body ID or role-aware archetype name")
    result.add_argument("--query", help="Search name, type, group, coupling, or stable key")
    result.add_argument("--record", help="Return one pairing production record by stable ID")
    result.add_argument("--list-groups", action="store_true", help="List canonical pairing groups")
    return result


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    args = parser().parse_args()
    catalog = PairingCatalog()
    try:
        if args.list_groups:
            output: Any = [dict(board_id=board_id, **group) for board_id, group in catalog.groups.items()]
        elif args.record:
            output = catalog.production_record(args.record)
        elif args.query:
            output = catalog.search(args.query, args.group)
        elif args.first and args.second:
            output = catalog.lookup(args.group or "m+f", args.first, args.second)
        else:
            parser().error("use --list-groups, --record, --query, or both --first and --second")
        print(json.dumps(output, ensure_ascii=False, indent=2))
        return 0
    except KeyError as error:
        parser().error(str(error))
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
