extends Node
class_name MissionRegistry

var missions := {}

func load_data() -> void:
    var mission_files := ["res://data/missions/mission_001.json", "res://data/missions/mission_002.json"]
    missions.clear()
    for path in mission_files:
        var data := JsonLoader.load_json(path)
        var mission_id := data.get("id", "")
        if mission_id != "":
            missions[mission_id] = data

func get_mission(mission_id: String) -> Dictionary:
    return missions.get(mission_id, {})
