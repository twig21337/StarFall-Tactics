extends Node
class_name UnitRegistry

var units: Dictionary = {}

func load_data() -> void:
    var data: Dictionary = JsonLoader.load_json("res://data/units/units_v1.json")
    units.clear()
    for entry in data.get("units", []):
        units[entry.get("id", "")] = entry

func get_unit(unit_id: String) -> Dictionary:
    return units.get(unit_id, {})
