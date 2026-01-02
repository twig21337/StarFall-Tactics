extends Node

var current_mission_id := "MIS_001_FOREST_APPROACH"
var battle_state: BattleState

func start_mission(mission_id: String) -> void:
    current_mission_id = mission_id
    Registries.ensure_loaded()
    var mission_data: Dictionary = Registries.missions.get_mission(mission_id)
    battle_state = BattleState.new()
    battle_state.setup_from_mission(mission_data)

func reset() -> void:
    battle_state = null
