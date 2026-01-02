extends Node
class_name CombatMath

static func compute_combat_stats(attacker: UnitModel, defender: UnitModel, map: MapModel) -> Dictionary:
    var weapon := Registries.weapons.get_weapon(attacker.weapon_id)
    var defender_weapon := Registries.weapons.get_weapon(defender.weapon_id)
    var triangle := TriangleSystem.get_triangle(weapon, defender_weapon)
    var tile := TerrainSystem.get_tile_data(map, defender.position)
    var atk := 0
    if weapon.get("category", "") == "MAGIC":
        atk = attacker.get_stat("mag") + weapon.get("might", 0)
    else:
        atk = attacker.get_stat("str") + weapon.get("might", 0)
    var def_total := defender.get_stat("def") + tile.get("def_bonus", 0)
    if weapon.get("category", "") == "MAGIC":
        def_total = defender.get_stat("res") + tile.get("res_bonus", 0)
    var dmg := max(0, atk - def_total + triangle.get("dmg_mod", 0))
    var hit := weapon.get("hit", 0) + attacker.get_stat("skl") * 2 + attacker.get_stat("lck")
    hit += triangle.get("hit_mod", 0)
    var avo := defender.get_stat("spd") * 2 + defender.get_stat("lck") + tile.get("avoid_bonus", 0)
    var hit_final := clamp(hit - avo, 10, 100)
    var crit := weapon.get("crit", 0) + int(floor(attacker.get_stat("skl") / 2.0))
    var crit_avo := defender.get_stat("lck")
    var crit_final := clamp(crit - crit_avo, 0, 30)
    var strikes := 1
    if attacker.get_stat("spd") >= defender.get_stat("spd") + 4:
        strikes = 2
    return {
        "dmg": dmg,
        "hit": hit_final,
        "crit": crit_final,
        "strikes": strikes,
        "triangle": triangle
    }
