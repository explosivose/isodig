class_name WorldEdit extends Node

var _world: World

func _init(world_node: World, player: Player):
  _world = world_node
  player.try_dig.connect(_on_player_try_dig)
  player.try_fill.connect(_on_player_try_fill)


func _on_player_try_dig(position: Vector3i) -> void:
  print('dig', position)
  _world.set_block(position, 0)
  # Update the _world view for the modified block and its neighbors
  _world.world_view.autopaint_cell(position, 0, _world.get_neighbor_values(position))
  # Update neighboring blocks' appearance since they might need to show new faces
  for neighbor_pos in _world.get_neighbors_on_layer(position):
    if neighbor_pos.z >= 0 and neighbor_pos.z < _world.Z:
      var value = _world.world_data[_world._get_index_for_vector(neighbor_pos)]
      _world.world_view.autopaint_cell(neighbor_pos, value, _world.get_neighbor_values(neighbor_pos))

func _on_player_try_fill(position: Vector3i) -> void:
  _world.set_block(position, 1)
  # Update the _world view for the modified block and its neighbors
  _world.world_view.autopaint_cell(position, 1, _world.get_neighbor_values(position))
  # Update neighboring blocks' appearance since they might need to show new faces
  for neighbor_pos in _world.get_neighbors_on_layer(position):
    if neighbor_pos.z >= 0 and neighbor_pos.z < _world.Z:
      var value = _world.world_data[_world._get_index_for_vector(neighbor_pos)]
      _world.world_view.autopaint_cell(neighbor_pos, value, _world.get_neighbor_values(neighbor_pos))
