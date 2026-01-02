extends Node
class_name MovementSystem

static func get_reachable_tiles(map: MapModel, start: Vector2i, move_points: int, occupied: Dictionary) -> Array:
    var reachable: Array = []
    var frontier := [start]
    var cost_so_far := {start: 0}
    while not frontier.is_empty():
        var current: Vector2i = frontier.pop_front()
        for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
            var next := current + dir
            if not map.in_bounds(next):
                continue
            var tile_id := map.get_tile_id(next)
            var tile := Registries.tiles.get_tile(tile_id)
            if tile.is_empty() or not tile.get("passable", true):
                continue
            var move_cost = tile.get("move_cost", 1)
            var new_cost := cost_so_far[current] + move_cost
            if new_cost > move_points:
                continue
            if occupied.has(next) and next != start:
                continue
            if not cost_so_far.has(next) or new_cost < cost_so_far[next]:
                cost_so_far[next] = new_cost
                frontier.append(next)
                if next != start:
                    reachable.append(next)
    return reachable

static func manhattan(a: Vector2i, b: Vector2i) -> int:
    return abs(a.x - b.x) + abs(a.y - b.y)
