class_name WorldNav
var _world: World
var _hints: WorldHints = WorldHints.new()
signal _has_moved_hints(nav: WorldNav, pos: Vector3i)

func _init(world: World, player: Player) -> void:
  _world = world
  player.try_move.connect(_try_move)
  player.try_climb.connect(_try_climb)
  player.try_descend.connect(_try_descend)
  player.has_moved.connect(_player_has_moved)
  _has_moved_hints.connect(_hints.refresh_hints)


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

func _try_move(player: Player, pos: Vector3i, dir: Vector3i) -> void:
  var new_pos = pos + Vector3i(dir.x, dir.y, 0)
  if _world.is_clear(new_pos):
    player.world_position = new_pos
    player.position = _world.world_view.map_to_local(new_pos)
    player.has_moved.emit(player, new_pos)
  else:
    print('cannot move')

func _try_climb(player: Player) -> void:
  var above = player.world_position + Vector3i.BACK
  if can_climb_to(above):
    player.world_position = above
    _world.world_view.update_view_point(Vector3i(above))
    _world.world_view.add_child_to_layer(above.z, player)
    player.position = _world.world_view.map_to_local(above)
    player.has_moved.emit(player, above)
  else:
    print('cannot climb')

func _try_descend(player: Player) -> void:
  var below = player.world_position + Vector3i.FORWARD
  if can_climb_to(below):
    player.world_position = below
    _world.world_view.update_view_point(Vector3i(below))
    _world.world_view.add_child_to_layer(below.z, player)
    player.has_moved.emit(player, below)
  else:
    print('cannot descend')

func _player_has_moved(_player: Player, new_pos: Vector3i) -> void:
  _has_moved_hints.emit(self, new_pos)

# TODO add climb and descend arrow sprites as player moves ?
