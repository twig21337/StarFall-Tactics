extends Node
class_name TargetingSystem

static func get_targets_in_range(attacker: UnitModel, units: Array, weapon: Dictionary) -> Array:
    var result: Array = []
    if weapon.is_empty():
        return result
    var range = weapon.get("range", {})
    var min_range = range.get("min", 1)
    var max_range = range.get("max", 1)
    for unit in units:
        if unit.side == attacker.side:
            continue
        var dist := abs(attacker.position.x - unit.position.x) + abs(attacker.position.y - unit.position.y)
        if dist >= min_range and dist <= max_range:
            result.append(unit)
    return result

static func can_counter(defender: UnitModel, attacker: UnitModel, weapon: Dictionary) -> bool:
    if weapon.is_empty():
        return false
    var range = weapon.get("range", {})
    var min_range = range.get("min", 1)
    var max_range = range.get("max", 1)
    var dist := abs(defender.position.x - attacker.position.x) + abs(defender.position.y - attacker.position.y)
    return dist >= min_range and dist <= max_range
