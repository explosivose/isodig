class_name WorldLayer

extends TileMapLayer

const CUBE_GREEN = Vector2i(0, 0)
const CUBE_GRAY = Vector2i(0, 3)
const CUBE_ORANGE = Vector2i(0, 6)
var depth = 0
  
func set_depth(new_depth: int, max_depth: int) -> void:
  depth = new_depth
  var color = Color(randf(), randf(), randf())
  var layer_color = color.lerp(color.darkened(0.7), 1 - float(depth) / max_depth)
  modulate = layer_color
  
func set_transparent(transparent: bool) -> void:
  modulate.a = 0.5 if transparent else 1


func paint_cell(coords: Vector2i):
  set_cell(coords, 0, CUBE_GREEN)

# func _input(event: InputEvent) -> void:
#   if event is InputEventMouseMotion:
#     var camera = get_viewport().get_camera_2d()
#     var coords = local_to_map(camera.get_global_mouse_position())
#     paint_cell(coords)
