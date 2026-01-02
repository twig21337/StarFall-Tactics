extends Node
class_name CombatResolver

static func resolve(attacker: UnitModel, defender: UnitModel, map: MapModel) -> Dictionary:
    var log := []
    var attacker_stats := CombatMath.compute_combat_stats(attacker, defender, map)
    var defender_weapon := Registries.weapons.get_weapon(defender.weapon_id)
    _apply_strikes(attacker, defender, attacker_stats, log)
    if defender.hp > 0 and TargetingSystem.can_counter(defender, attacker, defender_weapon):
        var counter_stats := CombatMath.compute_combat_stats(defender, attacker, map)
        _apply_strikes(defender, attacker, counter_stats, log)
    return {"log": log}

static func _apply_strikes(attacker: UnitModel, defender: UnitModel, stats: Dictionary, log: Array) -> void:
    for i in range(stats.get("strikes", 1)):
        if defender.hp <= 0:
            return
        var hit_roll := _roll_2rn()
        var hit := hit_roll < stats.get("hit", 0)
        var crit := false
        var dmg := 0
        if hit:
            crit = randi_range(0, 99) < stats.get("crit", 0)
            dmg = stats.get("dmg", 0)
            if crit:
                dmg *= 3
            defender.hp = max(0, defender.hp - dmg)
        log.append({
            "attacker": attacker.name,
            "defender": defender.name,
            "hit": hit,
            "crit": crit,
            "dmg": dmg
        })

static func _roll_2rn() -> float:
    var roll1 := randi_range(0, 99)
    var roll2 := randi_range(0, 99)
    return (roll1 + roll2) / 2.0
