class_name WorldNav 
var _world: World

func _init(world: World) -> void:
  _world = world

func can_climb_to(pos: Vector3i) -> bool:
  if pos.z >= _world.Z or pos.z < 0:
    return false
  # check if pos is clear
  if not _world.is_clear(pos):
    return false
  # and if any direct neighbor is a block
  var neighbors = _world.get_neighbors_on_layer(pos)
  if neighbors.any(func(n): return _world.is_block(n)):
    return true
  return false

func _try_move(player: Player, pos: Vector3i, dir: Vector2i) -> void:
  var new_pos = pos + Vector3i(dir.x, dir.y, 0)
  if _world.is_clear(new_pos):
    player.world_position = new_pos
    player.position = _world.world_view.map_to_local(new_pos)
  else:
    print('cannot move')

func _try_climb(player: Player) -> void:
  var above = player.world_position + Vector3i.BACK
  if can_climb_to(above):
    player.world_position = above
    _world.world_view.update_view_point(Vector3i(above))
    _world.world_view.add_child_to_layer(above.z, player)
    player.position = _world.world_view.map_to_local(above)
  else:
    print('cannot climb')

func _try_descend(player: Player) -> void:
  var below = player.world_position + Vector3i.FORWARD
  if can_climb_to(below):
    player.world_position = below
    _world.world_view.update_view_point(Vector3i(below))
    _world.world_view.add_child_to_layer(below.z, player)
  else:
    print('cannot descend')
