# responsible for orchestrating render WorldLayers for a cohesive view

class_name WorldView extends Node2D

const TILE_VERTICAL = 16
const WorldLayerScene = preload("res://src/scenes/world_layer.tscn")

var view_point: Vector3i
var layers: Array = []

func _init(world_size: Vector3i):
  view_point = Vector3i(0, 0, 0)
  for z in range(world_size.z):
    var layer = WorldLayerScene.instantiate()
    layer.name = "layer_%d" % z
    layer.position = Vector2(0, -z * TILE_VERTICAL)
    layer.set_depth(z, world_size.z)
    layers.append(layer)
    add_child(layer)

func paint_cell(pos: Vector3i) -> void:
  if pos.z >= 0 and pos.z < layers.size():
    layers[pos.z].paint_cell(Vector2i(pos.x, pos.y))

func get_layer(z: int) -> WorldLayer:
  if z >= 0 and z < layers.size():
    return layers[z]
  return null

func set_layer_transparent(z: int, transparent: bool) -> void:
  if z >= 0 and z < layers.size():
    layers[z].set_transparent(transparent)

func map_to_local(pos: Vector3i) -> Vector2:
  if pos.z >= 0 and pos.z < layers.size():
    return layers[pos.z].map_to_local(Vector2i(pos.x, pos.y))
  return Vector2.ZERO

func add_child_to_layer(z: int, child: Node) -> void:
  if z >= 0 and z < layers.size():
    if child.get_parent():
      child.get_parent().remove_child(child)
    layers[z].add_child(child)
  else:
    push_error("Layer index out of bounds: %d" % z)

func update_view_point(new_view_point: Vector3i) -> void:
  view_point = new_view_point
  update_view()

func update_view():
  for z in range(layers.size()):
    var layer = layers[z]
    if z > view_point.z + 1:
      layer.set_visible(false)
    elif z == view_point.z + 1:
      layer.set_visible(true)
      layer.modulate.a = 0.2
    elif z == view_point.z:
      layer.set_visible(true)
      layer.modulate.a = 0.5
    else:
      layer.set_visible(true)
      layer.set_transparent(false)
    
