extends Control

@onready var label: Label = $Label

func set_unit(unit: UnitModel) -> void:
    if unit == null:
        label.text = "Selected: -"
        return
    label.text = "Selected: %s HP %d/%d" % [unit.name, unit.hp, unit.max_hp]
