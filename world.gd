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
  player.try_climb.connect(_on_player_try_climb)
  player.try_descend.connect(_on_player_try_descend)

  world_data = PackedInt64Array()
  world_data.resize(X * Y * Z)
  world_data.fill(0)
  for x in range(X):
    for y in range(Y):
      for z in range(Z):
        var index = _get_index(x, y, z)
        world_data[index] = 1 if randf() > 0.7 else 0

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
  var index = x + y * X + z * X * Y
  if index < 0:
    return 0
  if index >= world_data.size():
    return world_data.size() - 1
  return index;

func _get_index_for_vector(pos: Vector3i) -> int:
  return _get_index(pos.x, pos.y, pos.z)

func _on_player_try_move(p: Player, pos: Vector3i, dir: Vector2i) -> void:
  # check if player can move
  print('try move')
  var new_pos = pos + Vector3i(dir.x, dir.y, 0)
  if is_clear(new_pos):
    p.world_position = new_pos
    p.position = layers[pos.z].map_to_local(Vector2i(new_pos.x, new_pos.y))
  else:
    print('cannot move')
    
func _on_player_try_climb(p: Player, pos: Vector3i) -> void:
  print('try climb')
  var above = pos + Vector3i.BACK
  if can_climb_to(above):
    p.world_position = above
    layers[pos.z].remove_child(p)
    layers[above.z].add_child(p)
    layers[above.z].set_transparent(false)
    p.position = layers[above.z].map_to_local(Vector2i(above.x, above.y))
  else:
    print('cannot climb')
    
  
func _on_player_try_descend(p: Player, pos: Vector3i) -> void:
  print('try descend')
  var below = pos + Vector3i.FORWARD
  if can_climb_to(below):
    p.world_position = below
    layers[pos.z].remove_child(p)
    layers[pos.z].set_transparent(true)
    layers[below.z].add_child(p)
    p.position = layers[below.z].map_to_local(Vector2i(below.x, below.y))
  else:
    print('cannot descend')


func set_block(pos: Vector3i, value: int) -> void:
  var index = _get_index_for_vector(pos)
  world_data[index] = value
  
func is_clear(pos: Vector3i) -> bool:
  var index = _get_index_for_vector(pos)
  return world_data[index] == 0

func is_block(pos: Vector3i) -> bool:
  var index = _get_index_for_vector(pos)
  return world_data[index] == 1

func get_neighbors_on_layer(pos: Vector3i) -> Array:
  var neighbors = []
  for x in range(-1, 2):
    for y in range(-1, 2):
      if x == 0 and y == 0:
        continue
      neighbors.append(pos + Vector3i(x, y, 0))
  return neighbors

func can_climb_to(pos: Vector3i) -> bool:
  if pos.z >= Z or pos.z < 0:
    return false
  # check if pos is clear
  if not is_clear(pos):
    return false
  # and if any direct neighbor is a block
  var neighbors = get_neighbors_on_layer(pos)
  if neighbors.any(func(n): return is_block(n)):
    return true
  return false
