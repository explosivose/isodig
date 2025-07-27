"""
Places hints in the world around a position based on navigation possibilities.
"""
class_name WorldHints extends Node

const HINT_UP = preload("res://src/world_hints/arrow_up.tscn")
var _pool_hints_up: NodePool = NodePool.new(HINT_UP, 10)

const HINT_DOWN = preload("res://src/world_hints/arrow_down.tscn")
var _pool_hints_down: NodePool = NodePool.new(HINT_DOWN, 10)

func refresh_hints(world_nav: WorldNav, world_position: Vector3i) -> void:
  var directions = [
    Vector3i(0, 0, 0),
    Vector3i(1, 0, 0),
    Vector3i(-1, 0, 0),
    Vector3i(0, 1, 0),
    Vector3i(0, -1, 0)
  ]
  for i in range(directions.size()):
    var dir = directions[i]
    var hint_up: Node2D = _pool_hints_up.get_at(i) as Node2D
    var hint_down: Node2D = _pool_hints_down.get_at(i) as Node2D
    var neighbor_pos = world_position + dir + Vector3i.BACK
    if world_nav.can_climb_to(neighbor_pos):
      hint_up.visible = true
      hint_up.position = world_nav._world.world_view.map_to_local(neighbor_pos)
      world_nav._world.world_view.add_child_to_layer(neighbor_pos.z, hint_up)
    else:
      hint_up.visible = false
    neighbor_pos = world_position + dir + Vector3i.FORWARD
    if world_nav.can_climb_to(neighbor_pos):
      hint_down.visible = true
      hint_down.position = world_nav._world.world_view.map_to_local(neighbor_pos)
      world_nav._world.world_view.add_child_to_layer(neighbor_pos.z, hint_down)
    else:
      hint_down.visible = false
  
