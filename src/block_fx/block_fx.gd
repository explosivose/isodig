class_name BlockFx

enum Action {
  BREAK,
  PLACE,
  HIT
}

var _pool_break = NodePool.new(preload("res://src/block_fx/block_break.tscn"), 10)
var _pool_place = NodePool.new(preload("res://src/block_fx/block_place.tscn"), 10)
var _pool_hit = NodePool.new(preload("res://src/block_fx/block_hit.tscn"), 10)

static func create_block_fx():
  return BlockFx.new()

func create_fx(world: World, position: Vector3i, action: Action) -> Node2D:
  var fx: Node2D
  if action == Action.BREAK:
    fx = _pool_break.get_next() as Node2D
  elif action == Action.PLACE:
    fx = _pool_place.get_next() as Node2D
  elif action == Action.HIT:
    fx = _pool_hit.get_next() as Node2D
  else:
    return null
  
  fx.position = world.world_view.map_to_local(position)
  world.world_view.add_child_to_layer(position.z, fx)
  var sfx = fx.get_node('sfx')
  if sfx:
    sfx.play()
  
  return fx
