extends Control

@onready var label: Label = $Label

func set_forecast(forecast: Dictionary) -> void:
    if forecast.is_empty():
        label.text = "Forecast: -"
        return
    var atk := forecast.get("attacker", {})
    var counter := forecast.get("defender_counter", null)
    var text := "ATK Dmg %d Hit %d Crit %d x%d" % [atk.get("dmg", 0), atk.get("hit", 0), atk.get("crit", 0), atk.get("strikes", 1)]
    if counter != null:
        text += " | CTR Dmg %d Hit %d Crit %d x%d" % [counter.get("dmg", 0), counter.get("hit", 0), counter.get("crit", 0), counter.get("strikes", 1)]
    text += " | Tri %s" % forecast.get("triangle_label", "NEU")
    var terrain := forecast.get("terrain_label", "")
    if terrain != "":
        text += " | %s" % terrain
    label.text = text
