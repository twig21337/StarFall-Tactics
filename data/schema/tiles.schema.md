# tiles_v1.json
- version: int
- tiles: array of Tile
Tile:
- id (string, unique)
- name (string)
- passable (bool)
- move_cost (int)
- avoid_bonus (int)
- def_bonus (int)
- res_bonus (int)
- tags (string[])
- sprite_key (string)
