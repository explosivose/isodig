class_name WorldEdit extends Node


const BLOCK_BREAK = preload("res://src/scenes/block_break.tscn")
const BLOCK_PLACE = preload("res://src/scenes/block_place.tscn")

# TODO create generic pool class
var _pool_block_break: Array = []
var _pool_block_break_index = 0
var _pool_block_place: Array = []
var _pool_block_place_index = 0

var _world: World

func _init(world_node: World, player: Player):
  _world = world_node
  player.try_dig.connect(_on_player_try_dig)
  player.try_fill.connect(_on_player_try_fill)
  for i in range(10):
    _pool_block_break.append(BLOCK_BREAK.instantiate())
    _pool_block_place.append(BLOCK_PLACE.instantiate())

func _get_next_block_break() -> Node2D:
  var block_break: Node2D = _pool_block_break[_pool_block_break_index]
  _pool_block_break_index += 1
  if _pool_block_break_index >= _pool_block_break.size():
    _pool_block_break_index = 0
  return block_break

func _get_next_block_place() -> Node2D:
  var block_place: Node2D = _pool_block_place[_pool_block_place_index]
  _pool_block_place_index += 1
  if _pool_block_place_index >= _pool_block_place.size():
    _pool_block_place_index = 0
  return block_place

func _on_player_try_dig(position: Vector3i) -> void:
  print('dig', position)
  _world.set_block(position, 0)
  # Update the _world view for the modified block and its neighbors
  _world.world_view.autopaint_cell(position, 0, _world.get_neighbor_values(position))
  var block_break: Node2D = _get_next_block_break()
  block_break.position = _world.world_view.map_to_local(position)
  _world.world_view.add_child_to_layer(position.z, block_break)
  block_break.get_node('sfx').play()
  # Update neighboring blocks' appearance since they might need to show new faces
  for neighbor_pos in _world.get_neighbors_on_layer(position):
    if neighbor_pos.z >= 0 and neighbor_pos.z < _world.Z:
      var value = _world.world_data[_world._get_index_for_vector(neighbor_pos)]
      _world.world_view.autopaint_cell(neighbor_pos, value, _world.get_neighbor_values(neighbor_pos))

func _on_player_try_fill(position: Vector3i) -> void:
  _world.set_block(position, 1)
  # Update the _world view for the modified block and its neighbors
  _world.world_view.autopaint_cell(position, 1, _world.get_neighbor_values(position))
  var block_place: Node2D = _get_next_block_place()
  block_place.position = _world.world_view.map_to_local(position)
  _world.world_view.add_child_to_layer(position.z, block_place)
  block_place.get_node('sfx').play()
  # Update neighboring blocks' appearance since they might need to show new faces
  for neighbor_pos in _world.get_neighbors_on_layer(position):
    if neighbor_pos.z >= 0 and neighbor_pos.z < _world.Z:
      var value = _world.world_data[_world._get_index_for_vector(neighbor_pos)]
      _world.world_view.autopaint_cell(neighbor_pos, value, _world.get_neighbor_values(neighbor_pos))
