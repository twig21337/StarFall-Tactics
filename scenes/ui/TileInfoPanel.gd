extends Control

@onready var label: Label = $Label

func set_tile(tile: Dictionary) -> void:
    if tile.is_empty():
        label.text = "Tile: -"
        return
    label.text = "Tile: %s" % TerrainSystem.get_terrain_label(tile)
