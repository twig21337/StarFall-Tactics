extends Node2D

@onready var grid: GridRenderer = $GridRenderer
@onready var selected_panel = $CanvasLayer/SelectedUnitPanel
@onready var tile_panel = $CanvasLayer/TileInfoPanel
@onready var forecast_panel = $CanvasLayer/ForecastPanel
@onready var command_menu = $CanvasLayer/CommandMenu
@onready var tutorial_popup = $CanvasLayer/TutorialPopup

var battle_state: BattleState
var ui_state := CombatUIState.new()

func _ready() -> void:
    randomize()
    battle_state = Game.battle_state
    if battle_state == null:
        push_warning("CombatScreen: Missing battle state")
        return
    ui_state.cursor = _first_player_pos()
    TurnSystem.start_player_phase(battle_state)
    grid.set_state(battle_state, ui_state)
    _update_panels()
    _trigger_turn_start()

func _unhandled_input(event: InputEvent) -> void:
    if battle_state == null:
        return
    if tutorial_popup.visible:
        if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
            tutorial_popup.hide_popup()
        return
    if event.is_action_pressed("ui_cancel"):
        _cancel_action()
        return
    if event.is_action_pressed("ui_up"):
        _move_cursor(Vector2i.UP)
    elif event.is_action_pressed("ui_down"):
        _move_cursor(Vector2i.DOWN)
    elif event.is_action_pressed("ui_left"):
        _move_cursor(Vector2i.LEFT)
    elif event.is_action_pressed("ui_right"):
        _move_cursor(Vector2i.RIGHT)
    elif event.is_action_pressed("ui_accept"):
        _confirm_action()
    elif event.is_action_pressed("ui_page_up"):
        _cycle_units()

func _move_cursor(dir: Vector2i) -> void:
    if ui_state.mode == "COMMAND_MENU":
        command_menu.move_selection(dir.y)
        return
    var next := ui_state.cursor + dir
    if battle_state.map.in_bounds(next):
        ui_state.cursor = next
        _update_panels()
        grid.update()

func _confirm_action() -> void:
    match ui_state.mode:
        "IDLE":
            var unit := battle_state.get_unit_at(ui_state.cursor)
            if unit != null and unit.side == "PLAYER" and not unit.has_acted:
                ui_state.selected_unit = unit
                ui_state.mode = "MOVE_SELECT"
                ui_state.movement_tiles = _compute_movement_tiles(unit)
        "MOVE_SELECT":
            _confirm_move()
        "COMMAND_MENU":
            var selection := command_menu.get_selected()
            if selection == "Attack":
                ui_state.mode = "TARGET_SELECT"
                command_menu.hide_menu()
            elif selection == "Wait":
                _finish_unit_action()
        "TARGET_SELECT":
            _confirm_attack()
    _update_panels()
    grid.update()

func _confirm_move() -> void:
    if ui_state.selected_unit == null:
        return
    var target := ui_state.cursor
    var occupied := battle_state.get_unit_at(target)
    if occupied != null and occupied != ui_state.selected_unit:
        return
    if target != ui_state.selected_unit.position and not ui_state.movement_tiles.has(target):
        return
    ui_state.selected_unit.position = target
    _trigger_enter_tile(ui_state.selected_unit)
    var targets := TargetingSystem.get_targets_in_range(ui_state.selected_unit, battle_state.get_units_by_side("ENEMY"), Registries.weapons.get_weapon(ui_state.selected_unit.weapon_id))
    if targets.is_empty():
        _finish_unit_action()
    else:
        command_menu.show_options(["Attack", "Wait"])
        ui_state.mode = "COMMAND_MENU"

func _confirm_attack() -> void:
    if ui_state.selected_unit == null:
        return
    var target := battle_state.get_unit_at(ui_state.cursor)
    if target == null or target.side != "ENEMY":
        return
    var weapon := Registries.weapons.get_weapon(ui_state.selected_unit.weapon_id)
    var dist := MovementSystem.manhattan(ui_state.selected_unit.position, target.position)
    var range = weapon.get("range", {})
    if dist < range.get("min", 1) or dist > range.get("max", 1):
        return
    _trigger_target_unit(ui_state.selected_unit, target)
    var result := CombatResolver.resolve(ui_state.selected_unit, target, battle_state.map)
    _apply_combat_result(result, target)
    _finish_unit_action()

func _apply_combat_result(_result: Dictionary, target: UnitModel) -> void:
    _check_unit_down(target)
    _check_unit_down(ui_state.selected_unit)
    _check_victory_conditions()

func _finish_unit_action() -> void:
    if ui_state.selected_unit != null:
        ui_state.selected_unit.has_acted = true
    ui_state.selected_unit = null
    ui_state.mode = "IDLE"
    ui_state.movement_tiles.clear()
    command_menu.hide_menu()
    if _all_player_acted():
        _start_enemy_phase()

func _cancel_action() -> void:
    if ui_state.mode == "MOVE_SELECT" or ui_state.mode == "TARGET_SELECT":
        ui_state.mode = "IDLE"
        ui_state.selected_unit = null
        ui_state.movement_tiles.clear()
        command_menu.hide_menu()
        _update_panels()
        grid.update()
    elif ui_state.mode == "COMMAND_MENU":
        ui_state.mode = "MOVE_SELECT"
        command_menu.hide_menu()

func _update_panels() -> void:
    selected_panel.set_unit(ui_state.selected_unit)
    tile_panel.set_tile(TerrainSystem.get_tile_data(battle_state.map, ui_state.cursor))
    if ui_state.mode == "TARGET_SELECT" and ui_state.selected_unit != null:
        var target := battle_state.get_unit_at(ui_state.cursor)
        if target != null and target.side != ui_state.selected_unit.side:
            var forecast := ForecastSystem.build_forecast(ui_state.selected_unit, target, battle_state.map)
            forecast_panel.set_forecast(forecast)
        else:
            forecast_panel.set_forecast({})
    else:
        forecast_panel.set_forecast({})

func _compute_movement_tiles(unit: UnitModel) -> Array:
    var occ := _build_occupancy(unit)
    return MovementSystem.get_reachable_tiles(battle_state.map, unit.position, unit.get_stat("mov"), occ)

func _build_occupancy(ignore: UnitModel) -> Dictionary:
    var occ: Dictionary = {}
    for unit in battle_state.units:
        if unit == ignore:
            continue
        occ[unit.position] = unit
    return occ

func _all_player_acted() -> bool:
    for unit in battle_state.get_units_by_side("PLAYER"):
        if not unit.has_acted:
            return false
    return true

func _start_enemy_phase() -> void:
    TurnSystem.start_enemy_phase(battle_state)
    _trigger_turn_start()
    await _run_enemy_phase()
    if battle_state.winner != "":
        _go_to_results()
        return
    TurnSystem.advance_turn(battle_state)
    TurnSystem.start_player_phase(battle_state)
    _trigger_turn_start()
    ui_state.cursor = _first_player_pos()
    _update_panels()
    grid.update()

func _run_enemy_phase() -> void:
    for enemy in battle_state.get_units_by_side("ENEMY"):
        if enemy.hp <= 0:
            continue
        var action := AI.take_turn(battle_state, enemy)
        enemy.position = action.get("move", enemy.position)
        if action.get("type", "") == "attack":
            var target: UnitModel = action.get("target", null)
            if target != null:
                CombatResolver.resolve(enemy, target, battle_state.map)
                _check_unit_down(target)
                _check_unit_down(enemy)
                _check_victory_conditions()
                if battle_state.winner != "":
                    return
        enemy.has_acted = true
        await get_tree().create_timer(0.2).timeout
        grid.update()

func _check_unit_down(unit: UnitModel) -> void:
    if unit == null or unit.hp > 0:
        return
    if unit.side == "PLAYER":
        battle_state.injured_unit_ids.append(unit.source_id)
    battle_state.remove_unit(unit)

func _check_victory_conditions() -> void:
    if battle_state.winner != "":
        return
    var boss_spawn = battle_state.mission.objective.get("boss_spawn_id", "")
    if boss_spawn != "":
        var boss_alive := false
        for unit in battle_state.units:
            if unit.spawn_id == boss_spawn:
                boss_alive = true
                break
        if not boss_alive:
            battle_state.winner = "VICTORY"
            _go_to_results()
            return
    for condition in battle_state.mission.loss_conditions:
        if condition.get("type", "") == "TAG_DEFEATED":
            var tag = condition.get("tag", "")
            var tag_alive := false
            for unit in battle_state.units:
                if unit.side == "PLAYER" and unit.is_tagged(tag):
                    tag_alive = true
                    break
            if not tag_alive:
                battle_state.winner = "DEFEAT"
                _go_to_results()
                return

func _go_to_results() -> void:
    get_tree().change_scene_to_file("res://scenes/screens/ResultsScreen.tscn")

func _trigger_turn_start() -> void:
    var actions := TriggerSystem.process_event(battle_state, {"type": "TURN_START"})
    _handle_trigger_actions(actions)

func _trigger_enter_tile(unit: UnitModel) -> void:
    var tile_id := battle_state.map.get_tile_id(unit.position)
    var actions := TriggerSystem.process_event(battle_state, {
        "type": "UNIT_ENTERS_TILE",
        "unit_side": unit.side,
        "tile_id": tile_id
    })
    _handle_trigger_actions(actions)

func _trigger_target_unit(unit: UnitModel, target: UnitModel) -> void:
    var tag := ""
    if target.is_tagged("boss"):
        tag = "boss"
    var actions := TriggerSystem.process_event(battle_state, {
        "type": "UNIT_TARGETS_UNIT",
        "unit_side": unit.side,
        "target_tag": tag
    })
    _handle_trigger_actions(actions)

func _handle_trigger_actions(actions: Array) -> void:
    for action in actions:
        if action.get("type", "") == "SHOW_TUTORIAL":
            tutorial_popup.show_tutorial(action.get("title", "Tutorial"), action.get("body", ""))

func _first_player_pos() -> Vector2i:
    var players := battle_state.get_units_by_side("PLAYER")
    if players.is_empty():
        return Vector2i.ZERO
    return players[0].position

func _cycle_units() -> void:
    var units: Array = []
    for unit in battle_state.get_units_by_side("PLAYER"):
        if not unit.has_acted:
            units.append(unit)
    if units.is_empty():
        return
    var index := 0
    for i in range(units.size()):
        if units[i].position == ui_state.cursor:
            index = (i + 1) % units.size()
            break
    ui_state.cursor = units[index].position
    _update_panels()
    grid.update()
