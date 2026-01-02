extends Control

@onready var title_label: Label = $Panel/Title
@onready var body_label: Label = $Panel/Body

func show_tutorial(title: String, body: String) -> void:
    title_label.text = title
    body_label.text = body
    visible = true

func hide_popup() -> void:
    visible = false
