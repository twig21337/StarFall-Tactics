extends Resource
class_name UnitModel

var source_id := ""
var spawn_id := ""
var name := ""
var side := "PLAYER"
var tags: Array = []
var class_id := ""
var stats := {}
var max_hp := 0
var hp := 0
var weapon_id := ""
var inventory := []
var position := Vector2i.ZERO
var has_acted := false
var ai_profile := ""

func setup_player(unit_data: Dictionary) -> void:
    source_id = unit_data.get("id", "")
    name = unit_data.get("name", "")
    tags = unit_data.get("tags", [])
    class_id = unit_data.get("starting_class_id", "")
    stats = Registries.classes.get_class_data(class_id).get("base_stats", {}).duplicate()
    max_hp = stats.get("hp", 1)
    hp = max_hp
    side = "PLAYER"
    inventory = unit_data.get("inventory", [])
    weapon_id = _first_weapon_from_inventory(inventory)

func setup_enemy(enemy_data: Dictionary, spawn: Dictionary) -> void:
    source_id = enemy_data.get("id", "")
    spawn_id = spawn.get("spawn_id", "")
    name = enemy_data.get("name", "")
    tags = ["enemy"]
    if enemy_data.get("archetype", "") == "BOSS":
        tags.append("boss")
    class_id = enemy_data.get("class_like", "")
    stats = enemy_data.get("stats_override", {}).duplicate()
    max_hp = stats.get("hp", 1)
    hp = max_hp
    side = "ENEMY"
    weapon_id = enemy_data.get("weapon_id", "")
    ai_profile = spawn.get("ai_profile", enemy_data.get("ai_profile", "AI_AGGRO"))

func get_stat(stat_name: String) -> int:
    return stats.get(stat_name, 0)

func is_tagged(tag: String) -> bool:
    return tags.has(tag)

func _first_weapon_from_inventory(inv: Array) -> String:
    for entry in inv:
        if entry.has("weapon_id"):
            return entry["weapon_id"]
    return ""
