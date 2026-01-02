extends Node
class_name AI

static func take_turn(state: BattleState, unit: UnitModel) -> Dictionary:
    var weapon := Registries.weapons.get_weapon(unit.weapon_id)
    var enemies := state.get_units_by_side("PLAYER")
    var occupied := _build_occupancy(state.units, unit)
    var reachable := MovementSystem.get_reachable_tiles(state.map, unit.position, unit.get_stat("mov"), occupied)
    reachable.append(unit.position)
    var targets_now := TargetingSystem.get_targets_in_range(unit, enemies, weapon)
    if not targets_now.is_empty():
        return {"type": "attack", "target": _closest_unit(unit.position, targets_now), "move": unit.position}
    match unit.ai_profile:
        "AI_HOLD":
            return {"type": "wait", "move": unit.position}
        "AI_BOSS_FORT":
            return {"type": "wait", "move": unit.position}
        _:
            pass
    var best_tile := unit.position
    var best_target := _closest_unit(unit.position, enemies)
    var best_dist := MovementSystem.manhattan(unit.position, best_target.position)
    for tile in reachable:
        var dist := MovementSystem.manhattan(tile, best_target.position)
        if dist < best_dist:
            best_dist = dist
            best_tile = tile
    var moved_targets: Array = []
    for enemy in enemies:
        var dist := MovementSystem.manhattan(best_tile, enemy.position)
        var range = weapon.get("range", {})
        if dist >= range.get("min", 1) and dist <= range.get("max", 1):
            moved_targets.append(enemy)
    if not moved_targets.is_empty():
        return {"type": "attack", "target": _closest_unit(best_tile, moved_targets), "move": best_tile}
    if unit.ai_profile == "AI_RANGED":
        return {"type": "wait", "move": best_tile}
    return {"type": "wait", "move": best_tile}

static func _closest_unit(pos: Vector2i, units: Array) -> UnitModel:
    var best: UnitModel = units[0]
    var best_dist := MovementSystem.manhattan(pos, best.position)
    for unit in units:
        var dist := MovementSystem.manhattan(pos, unit.position)
        if dist < best_dist:
            best_dist = dist
            best = unit
    return best

static func _build_occupancy(units: Array, ignore: UnitModel) -> Dictionary:
    var occ: Dictionary = {}
    for unit in units:
        if unit == ignore:
            continue
        occ[unit.position] = unit
    return occ
