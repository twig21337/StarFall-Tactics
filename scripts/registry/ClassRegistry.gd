extends Node
class_name ClassRegistry

var classes := {}

func load_data() -> void:
    var data := JsonLoader.load_json("res://data/classes/classes_v1.json")
    classes.clear()
    for entry in data.get("classes", []):
        classes[entry.get("id", "")] = entry

func get_class(class_id: String) -> Dictionary:
    return classes.get(class_id, {})
