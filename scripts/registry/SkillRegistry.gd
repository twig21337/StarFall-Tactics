extends Node
class_name SkillRegistry

var skills: Dictionary = {}

func load_data() -> void:
    var data: Dictionary = JsonLoader.load_json("res://data/skills/skills_v1.json")
    skills.clear()
    for entry in data.get("skills", []):
        skills[entry.get("id", "")] = entry

func get_skill(skill_id: String) -> Dictionary:
    return skills.get(skill_id, {})
