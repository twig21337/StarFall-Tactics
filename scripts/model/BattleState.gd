extends Resource
class_name BattleState

var mission: MissionModel = MissionModel.new()
var map: MapModel = MapModel.new()
var units: Array = []
var phase := "PLAYER"
var turn := 1
var injured_unit_ids: Array = []
var winner := ""
var triggered_ids: Array = []

func setup_from_mission(mission_data: Dictionary) -> void:
    mission.from_data(mission_data)
    map.from_data(Registries.maps.get_map(mission.map_id))
    _spawn_player_units()
    _spawn_enemies()

func _spawn_player_units() -> void:
    units.clear()
    var required_tags: Array = mission.deployment.get("required_unit_tags", [])
    var max_units: int = mission.deployment.get("max_units", 4)
    var deploy_markers: Array = map.markers.get("player_deploy", [])
    var deployed := 0
    for unit_entry in Registries.units.units.values():
        if deployed >= max_units:
            break
        var unit := UnitModel.new()
        unit.setup_player(unit_entry)
        if required_tags.is_empty() or _has_any_tag(unit.tags, required_tags):
            var marker: Dictionary = deploy_markers[deployed]
            unit.position = Vector2i(marker.get("x", 0), marker.get("y", 0))
            units.append(unit)
            deployed += 1
    for unit_entry in Registries.units.units.values():
        if deployed >= max_units:
            break
        var unit := UnitModel.new()
        unit.setup_player(unit_entry)
        if not _has_any_tag(unit.tags, required_tags):
            var marker: Dictionary = deploy_markers[deployed]
            unit.position = Vector2i(marker.get("x", 0), marker.get("y", 0))
            units.append(unit)
            deployed += 1

func _spawn_enemies() -> void:
    var enemy_spawns: Array = mission.spawns.get("enemies", [])
    for spawn in enemy_spawns:
        var template: Dictionary = Registries.enemies.get_enemy(spawn.get("enemy_template_id", ""))
        var unit := UnitModel.new()
        unit.setup_enemy(template, spawn)
        var marker: Vector2i = _find_marker("enemy_spawn", spawn.get("spawn_id", ""))
        unit.position = marker
        units.append(unit)
    var boss_spawn: Dictionary = mission.spawns.get("boss", {})
    if boss_spawn.size() > 0:
        var template: Dictionary = Registries.enemies.get_enemy(boss_spawn.get("enemy_template_id", ""))
        var boss := UnitModel.new()
        boss.setup_enemy(template, boss_spawn)
        boss.tags.append("boss")
        var boss_marker: Vector2i = _find_marker("boss_spawn", boss_spawn.get("spawn_id", ""))
        boss.position = boss_marker
        units.append(boss)

func _find_marker(marker_type: String, spawn_id: String) -> Vector2i:
    var markers: Array = map.markers.get(marker_type, [])
    for marker in markers:
        if marker.get("spawn_id", "") == spawn_id:
            return Vector2i(marker.get("x", 0), marker.get("y", 0))
    if markers.size() > 0:
        return Vector2i(markers[0].get("x", 0), markers[0].get("y", 0))
    return Vector2i.ZERO

func _has_any_tag(tags: Array, required: Array) -> bool:
    for tag in required:
        if tags.has(tag):
            return true
    return false

func get_unit_at(pos: Vector2i) -> UnitModel:
    for unit in units:
        if unit.position == pos:
            return unit
    return null

func get_units_by_side(side: String) -> Array:
    var result: Array = []
    for unit in units:
        if unit.side == side:
            result.append(unit)
    return result

func remove_unit(unit: UnitModel) -> void:
    units.erase(unit)
