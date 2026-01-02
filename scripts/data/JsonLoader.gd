extends Node
class_name JsonLoader

static func load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_warning("JsonLoader: Missing file %s" % path)
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_warning("JsonLoader: Failed to open %s" % path)
        return {}
    var content := file.get_as_text()
    var result = JSON.parse_string(content)
    if result is Dictionary:
        return result
    push_warning("JsonLoader: Invalid JSON in %s" % path)
    return {}
