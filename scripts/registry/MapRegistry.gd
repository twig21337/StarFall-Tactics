extends Node
class_name MapRegistry

var maps: Dictionary = {}

func load_data() -> void:
    var map_files: Array = ["res://data/maps/map_001.json", "res://data/maps/map_002.json"]
    maps.clear()
    for path in map_files:
        var data: Dictionary = JsonLoader.load_json(path)
        var map_id = data.get("id", "")
        if map_id != "":
            maps[map_id] = data

func get_map(map_id: String) -> Dictionary:
    return maps.get(map_id, {})
