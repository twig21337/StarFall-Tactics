extends Node2D
class_name GridRenderer

const TILE_SIZE := 32

var battle_state: BattleState
var ui_state: CombatUIState

func _ready() -> void:
    set_process(false)

func set_state(state: BattleState, ui: CombatUIState) -> void:
    battle_state = state
    ui_state = ui
    update()

func _draw() -> void:
    if battle_state == null:
        return
    for y in range(battle_state.map.size.y):
        for x in range(battle_state.map.size.x):
            var pos: Vector2i = Vector2i(x, y)
            var tile_id: String = battle_state.map.get_tile_id(pos)
            var color: Color = _tile_color(tile_id)
            draw_rect(Rect2(Vector2(x, y) * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE)), color)
    for unit in battle_state.units:
        _draw_unit(unit)
    if ui_state != null:
        var cursor_rect: Rect2 = Rect2(Vector2(ui_state.cursor) * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
        draw_rect(cursor_rect, Color(1, 1, 0, 0.3), false, 2.0)

func _draw_unit(unit: UnitModel) -> void:
    var center: Vector2 = Vector2(unit.position) * TILE_SIZE + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
    var color: Color = Color(0.2, 0.6, 1.0) if unit.side == "PLAYER" else Color(1.0, 0.3, 0.3)
    if unit.has_acted:
        color = color.darkened(0.3)
    draw_circle(center, TILE_SIZE * 0.4, color)
    draw_string(ThemeDB.fallback_font, center + Vector2(-6, 6), unit.name.left(1), HORIZONTAL_ALIGNMENT_CENTER, TILE_SIZE, 12, Color.WHITE)

func _tile_color(tile_id: String) -> Color:
    match tile_id:
        "TILE_FOREST":
            return Color(0.1, 0.5, 0.1)
        "TILE_FORT":
            return Color(0.5, 0.4, 0.3)
        "TILE_WALL":
            return Color(0.2, 0.2, 0.2)
        "TILE_ROAD":
            return Color(0.6, 0.5, 0.3)
        "TILE_WATER":
            return Color(0.1, 0.3, 0.6)
        _:
            return Color(0.3, 0.7, 0.3)
