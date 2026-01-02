extends Node
class_name Registries

var tiles := TileRegistry.new()
var weapons := WeaponRegistry.new()
var items := ItemRegistry.new()
var skills := SkillRegistry.new()
var classes := ClassRegistry.new()
var units := UnitRegistry.new()
var enemies := EnemyRegistry.new()
var maps := MapRegistry.new()
var missions := MissionRegistry.new()

func _ready() -> void:
    _load_all()

func _load_all() -> void:
    tiles.load_data()
    weapons.load_data()
    items.load_data()
    skills.load_data()
    classes.load_data()
    units.load_data()
    enemies.load_data()
    maps.load_data()
    missions.load_data()

func ensure_loaded() -> void:
    if tiles.tiles.is_empty():
        _load_all()
