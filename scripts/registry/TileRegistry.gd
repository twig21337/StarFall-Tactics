extends Node
class_name TileRegistry

var tiles: Dictionary = {}

func load_data() -> void:
    var data: Dictionary = JsonLoader.load_json("res://data/tiles/tiles_v1.json")
    tiles.clear()
    for entry in data.get("tiles", []):
        tiles[entry.get("id", "")] = entry

func get_tile(tile_id: String) -> Dictionary:
    return tiles.get(tile_id, {})
