## Copyright © 2026 SeirVed. All rights reserved. See LICENSE.md.

class_name BreedingEngine
extends RefCounted

const TIER_BASE := {"common": 45, "mid": 70, "rare": 100}
const TIER_PRESSURE := {"common": 1.0, "mid": 1.35, "rare": 1.8}
const ELEMENTS := ["Earth", "Wind", "Fire", "Water", "Light", "Dark"]


static func breed(parent_a: Dictionary, parent_b: Dictionary, transaction: int) -> Dictionary:
	var pair_key := SpeciesDB.pair_key(parent_a.id, parent_b.id)
	var seed_text := "%s|%s|%d|%s" % [pair_key, transaction, int(parent_a.get("stability", 0.0) * 1000.0), parent_a.get("element", "Earth")]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_text.hash()

	var pressure_a := float(TIER_PRESSURE.get(parent_a.tier, 1.0)) * (1.0 + float(parent_a.stability) * 0.12)
	var pressure_b := float(TIER_PRESSURE.get(parent_b.tier, 1.0)) * (1.0 + float(parent_b.stability) * 0.12)
	var chosen: Dictionary = parent_a if rng.randf() < pressure_a / (pressure_a + pressure_b) else parent_b
	var other: Dictionary = parent_b if chosen.id == parent_a.id else parent_a
	var base := int(TIER_BASE.get(chosen.tier, 45))
	var stats := {"STR": base, "VIT": base, "SPD": base, "MAG": base, "DEF": base, "CHA": base}
	stats[chosen.bias] += 18
	stats[other.bias] += 9
	for stat in stats:
		stats[stat] = maxi(1, int(stats[stat]) + rng.randi_range(-7, 7))

	var stability := clampf((float(parent_a.stability) + float(parent_b.stability)) * 0.5 + rng.randf_range(-0.12, 0.12), -1.0, 1.0)
	var feral := clampf((float(parent_a.feral) + float(parent_b.feral)) * 0.5 + rng.randf_range(-0.10, 0.10), -1.0, 1.0)
	var development := clampf((float(parent_a.development) + float(parent_b.development)) * 0.5 + rng.randf_range(-0.10, 0.10), -1.0, 1.0)
	var element := str(parent_a.element if rng.randf() < 0.5 else parent_b.element)
	if element == "Variable":
		element = ELEMENTS[rng.randi_range(0, ELEMENTS.size() - 1)]

	var mutation := "None"
	if rng.randf() < 0.08 + maxf(0.0, -stability) * 0.22:
		mutation = ["Bright markings", "Oversized trait", "Latent element", "Rare temperament"][rng.randi_range(0, 3)]
	var pairing_plan := PairingProgress.build_pairing_plan(parent_a.id, parent_b.id)

	return {
		"species_id": chosen.id,
		"species_name": chosen.name,
		"emoji": chosen.emoji,
		"stats": stats,
		"element": element,
		"feral": feral,
		"development": development,
		"stability": stability,
		"mutation": mutation,
		"seed": seed_text.hash(),
		"generation": transaction,
		"pairing_plan": pairing_plan,
	}
