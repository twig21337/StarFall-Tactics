extends Control

func _ready() -> void:
    Game.start_mission("MIS_001_FOREST_APPROACH")
    await get_tree().create_timer(0.5).timeout
    get_tree().change_scene_to_file("res://scenes/screens/DeploymentScreen.tscn")
