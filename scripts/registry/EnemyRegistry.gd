extends Node
class_name EnemyRegistry

var enemies: Dictionary = {}

func load_data() -> void:
    var data := JsonLoader.load_json("res://data/enemies/enemies_v1.json")
    enemies.clear()
    for entry in data.get("enemies", []):
        enemies[entry.get("id", "")] = entry

func get_enemy(enemy_id: String) -> Dictionary:
    return enemies.get(enemy_id, {})
