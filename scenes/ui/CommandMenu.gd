extends Control

@onready var label: Label = $Label

var options: Array = []
var selected_index := 0

func show_options(list: Array) -> void:
    options = list
    selected_index = 0
    visible = true
    _refresh()

func hide_menu() -> void:
    visible = false

func move_selection(dir: int) -> void:
    if options.is_empty():
        return
    selected_index = clamp(selected_index + dir, 0, options.size() - 1)
    _refresh()

func get_selected() -> String:
    if options.is_empty():
        return ""
    return options[selected_index]

func _refresh() -> void:
    var lines: Array = []
    for i in range(options.size()):
        var prefix := "> " if i == selected_index else "  "
        lines.append(prefix + options[i])
    label.text = "Commands\n" + "\n".join(lines)
