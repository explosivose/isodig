# responsible for queries, mutations and side effects of world data

extends Node2D

const SIZE = 16
var X = SIZE
var Y = SIZE
var Z = 6

var world_data: PackedInt64Array
var world_view: WorldView
const PlayerScene = preload("res://src/scenes/player.tscn")
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

  world_view = WorldView.new(Vector3i(X, Y, Z))
  add_child(world_view)
  
  for x in range(X):
    for y in range(Y):
      for z in range(Z):
        var index = _get_index(x, y, z)
        var value = world_data[index]
        if value == 1:
          world_view.paint_cell(Vector3i(x, y, z))
        # world_view.autopaint_cell(Vector3i(x, y, z), value, get_neighbor_values(Vector3i(x, y, z)))
  
  world_view.get_layer(Z - 1).add_child(player)

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
  print('try move')
  var new_pos = pos + Vector3i(dir.x, dir.y, 0)
  if is_clear(new_pos):
    p.world_position = new_pos
    p.position = world_view.map_to_local(new_pos)
  else:
    print('cannot move')
  
func _on_player_try_climb(p: Player, pos: Vector3i) -> void:
  print('try climb')
  var above = pos + Vector3i.BACK
  if can_climb_to(above):
    p.world_position = above
    world_view.update_view_point(Vector3i(above))
    world_view.add_child_to_layer(above.z, p)
    p.position = world_view.map_to_local(above)
  else:
    print('cannot climb')
  
func _on_player_try_descend(p: Player, pos: Vector3i) -> void:
  print('try descend')
  var below = pos + Vector3i.FORWARD
  if can_climb_to(below):
    p.world_position = below
    world_view.update_view_point(Vector3i(below))
    world_view.add_child_to_layer(below.z, p)
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
  var directions = [
    Vector3i(1, 0, 0),
    Vector3i(-1, 0, 0),
    Vector3i(0, 1, 0),
    Vector3i(0, -1, 0),
    #Vector3i(0, 0, 1),
    #Vector3i(0, 0, -1)
  ]
  for dir in directions:
    neighbors.append(pos + dir)
  return neighbors

func get_neighbor_values(pos: Vector3i) -> PackedInt64Array:
  var neighbors: PackedInt64Array = PackedInt64Array()
  var directions: Array[Vector3i] = [
    Vector3i(1, 0, 0),
    Vector3i(-1, 0, 0),
    Vector3i(0, 1, 0),
    Vector3i(0, -1, 0),
    Vector3i(0, 0, 1),
    Vector3i(0, 0, -1)
  ]
  for dir in directions:
    neighbors.append(world_data[_get_index_for_vector(pos + dir)])
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

   
