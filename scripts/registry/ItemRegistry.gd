extends Node
class_name ItemRegistry

var items: Dictionary = {}

func load_data() -> void:
    var data: Dictionary = JsonLoader.load_json("res://data/items/items_v1.json")
    items.clear()
    for entry in data.get("items", []):
        items[entry.get("id", "")] = entry

func get_item(item_id: String) -> Dictionary:
    return items.get(item_id, {})
