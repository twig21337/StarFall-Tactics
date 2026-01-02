extends Node
class_name WeaponRegistry

var weapons: Dictionary = {}

func load_data() -> void:
    var data := JsonLoader.load_json("res://data/weapons/weapons_v1.json")
    weapons.clear()
    for entry in data.get("weapons", []):
        weapons[entry.get("id", "")] = entry

func get_weapon(weapon_id: String) -> Dictionary:
    return weapons.get(weapon_id, {})
