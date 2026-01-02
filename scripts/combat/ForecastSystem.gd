extends Node
class_name ForecastSystem

static func build_forecast(attacker: UnitModel, defender: UnitModel, map: MapModel) -> Dictionary:
    var attacker_weapon := Registries.weapons.get_weapon(attacker.weapon_id)
    var defender_weapon := Registries.weapons.get_weapon(defender.weapon_id)
    var attacker_stats := CombatMath.compute_combat_stats(attacker, defender, map)
    var counter = null
    if TargetingSystem.can_counter(defender, attacker, defender_weapon):
        counter = CombatMath.compute_combat_stats(defender, attacker, map)
    var terrain_label := TerrainSystem.get_terrain_label(TerrainSystem.get_tile_data(map, defender.position))
    return {
        "attacker": _pack(attacker_stats),
        "defender_counter": _pack(counter) if counter != null else null,
        "triangle_label": attacker_stats.get("triangle", {}).get("label", "NEU"),
        "terrain_label": terrain_label
    }

static func _pack(stats: Dictionary) -> Dictionary:
    if stats == null:
        return {}
    return {
        "dmg": stats.get("dmg", 0),
        "hit": stats.get("hit", 0),
        "crit": stats.get("crit", 0),
        "strikes": stats.get("strikes", 1)
    }
