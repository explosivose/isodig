extends Node2D

const TILE_VERTICAL = 16
const SIZE = 16
var X = SIZE
var Y = SIZE
var Z = 3

var world_data: PackedInt64Array
const WorldLayerScene = preload("res://world_layer.tscn")
var layers: Array
const PlayerScene = preload("res://player.tscn")
var player

func _ready():
  player = PlayerScene.instantiate()
  player.place_in_world(Vector3i(0, 0, Z - 1))
  player.try_move.connect(_on_player_try_move)

  world_data = PackedInt64Array()
  world_data.resize(X * Y * Z)
  world_data.fill(0)
  for x in range(X):
    for y in range(Y):
      for z in range(Z):
        var index = _get_index(x, y, z)
        world_data[index] = 1 if z < Z - 1 or randf() > 0.7 else 0

  for z in range(Z):
    var layer = WorldLayerScene.instantiate()
    layer.name = "layer_%d" % z
    layer.position = Vector2(0, -z * TILE_VERTICAL)
    layer.set_depth(z, Z)
    for x in range(X):
      for y in range(Y):
        var index = _get_index(x, y, z)
        var value = world_data[index]
        if (value == 1):
          layer.paint_cell(Vector2i(x, y))
    layers.append(layer)
    add_child(layer)
  layers[2].add_child(player)

func _get_index(x: int, y: int, z: int) -> int:
  return x + y * X + z * X * Y

func _get_index_for_vector(pos: Vector3i) -> int:
  return _get_index(pos.x, pos.y, pos.z)


func _on_player_try_move(p: Player, pos: Vector3i, dir: Vector2i) -> void:
  # check if player can move
  print('try move')
  var new_pos = pos + Vector3i(dir.x, dir.y, 0)
  if is_walkable(new_pos):
    p.world_position = new_pos
    p.position = layers[pos.z].map_to_local(Vector2i(new_pos.x, new_pos.y))
  else:
    print('cannot move')


func set_block(pos: Vector3i, value: int) -> void:
  var index = _get_index_for_vector(pos)
  world_data[index] = value
  
func is_walkable(pos: Vector3i) -> bool:
  var index = _get_index_for_vector(pos)
  return index < X * Y * Z and world_data[index] == 0
