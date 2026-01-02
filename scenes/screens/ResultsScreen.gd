extends Control

@onready var label: Label = $Label

func _ready() -> void:
    var state: BattleState = Game.battle_state
    var result: String = state.winner if state != null else "DEFEAT"
    var injured: Array = []
    if state != null:
        injured = state.injured_unit_ids
    var text: String = "%s\nInjured: %s\nPress Enter" % [result, ", ".join(injured)]
    label.text = text

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        Game.reset()
        get_tree().change_scene_to_file("res://scenes/screens/CampaignMenu.tscn")
