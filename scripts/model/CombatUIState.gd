extends Resource
class_name CombatUIState

var cursor := Vector2i.ZERO
var selected_unit: UnitModel
var movement_tiles: Array = []
var mode := "IDLE"
var target_unit: UnitModel
