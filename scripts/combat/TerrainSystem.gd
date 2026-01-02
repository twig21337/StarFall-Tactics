extends Node
class_name TerrainSystem

static func get_tile_data(map: MapModel, pos: Vector2i) -> Dictionary:
    var tile_id := map.get_tile_id(pos)
    return Registries.tiles.get_tile(tile_id)

static func get_terrain_label(tile: Dictionary) -> String:
    if tile.is_empty():
        return ""
    var parts := []
    var avoid := tile.get("avoid_bonus", 0)
    var def_bonus := tile.get("def_bonus", 0)
    if avoid != 0:
        parts.append("%+d Avo" % avoid)
    if def_bonus != 0:
        parts.append("%+d Def" % def_bonus)
    if parts.is_empty():
        return "%s" % tile.get("name", "Tile")
    return "%s (%s)" % [tile.get("name", "Tile"), ", ".join(parts)]

static func apply_fort_heal(units: Array, map: MapModel) -> void:
    for unit in units:
        var tile := get_tile_data(map, unit.position)
        if tile.get("id", "") == "TILE_FORT":
            var heal_amount := max(1, int(ceil(unit.max_hp * 0.1)))
            unit.hp = min(unit.max_hp, unit.hp + heal_amount)
