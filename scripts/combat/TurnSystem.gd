extends Node
class_name TurnSystem

static func start_player_phase(state: BattleState) -> void:
    state.phase = "PLAYER"
    for unit in state.get_units_by_side("PLAYER"):
        unit.has_acted = false
    TerrainSystem.apply_fort_heal(state.get_units_by_side("PLAYER"), state.map)

static func start_enemy_phase(state: BattleState) -> void:
    state.phase = "ENEMY"
    for unit in state.get_units_by_side("ENEMY"):
        unit.has_acted = false
    TerrainSystem.apply_fort_heal(state.get_units_by_side("ENEMY"), state.map)

static func advance_turn(state: BattleState) -> void:
    state.turn += 1
