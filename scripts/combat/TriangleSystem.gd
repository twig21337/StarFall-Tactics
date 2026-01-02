extends Node
class_name TriangleSystem

static func get_triangle(attacker_weapon: Dictionary, defender_weapon: Dictionary) -> Dictionary:
    var result := {"hit_mod": 0, "dmg_mod": 0, "label": "NEU"}
    if attacker_weapon.is_empty() or defender_weapon.is_empty():
        return result
    if attacker_weapon.get("category", "") != "MELEE":
        return result
    if defender_weapon.get("category", "") != "MELEE":
        return result
    var atk_type := attacker_weapon.get("subtype", "")
    var def_type := defender_weapon.get("subtype", "")
    var valid := ["SWORD", "AXE", "SPEAR"]
    if not valid.has(atk_type) or not valid.has(def_type):
        return result
    if atk_type == def_type:
        return result
    var advantage := {
        "SWORD": "AXE",
        "AXE": "SPEAR",
        "SPEAR": "SWORD"
    }
    if advantage.get(atk_type, "") == def_type:
        result.hit_mod = 15
        result.dmg_mod = 1
        result.label = "ADV"
    elif advantage.get(def_type, "") == atk_type:
        result.hit_mod = -15
        result.dmg_mod = -1
        result.label = "DIS"
    return result
