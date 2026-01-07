extends Resource
class_name MapModel

var id := ""
var name := ""
var size := Vector2i.ZERO
var terrain_grid: Array = []
var markers: Dictionary = {}
var legend: Dictionary = {}

func from_data(data: Dictionary) -> void:
    id = data.get("id", "")
    name = data.get("name", "")
    var size_data = data.get("size", {})
    size = Vector2i(size_data.get("w", 0), size_data.get("h", 0))
    legend = data.get("legend", {})
    markers = data.get("markers", {})
    terrain_grid.clear()
    var rows: Array = data.get("layers", {}).get("terrain", [])
    for row in rows:
        var row_tiles: Array = []
        for ch in row:
            var tile_id = legend.get(ch, "TILE_PLAIN")
            row_tiles.append(tile_id)
        terrain_grid.append(row_tiles)

func get_tile_id(pos: Vector2i) -> String:
    if pos.y < 0 or pos.y >= terrain_grid.size():
        return ""
    var row: Array = terrain_grid[pos.y]
    if pos.x < 0 or pos.x >= row.size():
        return ""
    return row[pos.x]

func in_bounds(pos: Vector2i) -> bool:
    return pos.x >= 0 and pos.y >= 0 and pos.x < size.x and pos.y < size.y
