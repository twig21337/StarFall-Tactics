extends Resource
class_name MissionModel

var id := ""
var name := ""
var map_id := ""
var objective: Dictionary = {}
var loss_conditions: Array = []
var deployment: Dictionary = {}
var spawns: Dictionary = {}
var triggers: Array = []

func from_data(data: Dictionary) -> void:
    id = data.get("id", "")
    name = data.get("name", "")
    map_id = data.get("map_id", "")
    objective = data.get("objective", {})
    loss_conditions = data.get("loss_conditions", [])
    deployment = data.get("deployment", {})
    spawns = data.get("spawns", {})
    triggers = data.get("triggers", [])
