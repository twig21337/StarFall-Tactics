extends Control

@onready var label: Label = $Label

func _ready() -> void:
    var state := Game.battle_state
    var result := state.winner if state != null else "DEFEAT"
    var injured := []
    if state != null:
        injured = state.injured_unit_ids
    var text := "%s\nInjured: %s\nPress Enter" % [result, ", ".join(injured)]
    label.text = text

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        Game.reset()
        get_tree().change_scene_to_file("res://scenes/screens/CampaignMenu.tscn")
