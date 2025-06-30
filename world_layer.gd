class_name WorldLayer

extends TileMapLayer

  
func set_depth(depth: int, max_depth: int):
  var color = Color(randf(), randf(), randf())
  var layer_color = color.lerp(color.darkened(0.7), 1 - float(depth) / max_depth)
  modulate = layer_color


func paint_cell(coords: Vector2i):
  set_cell(coords, 0, Vector2i(0, 0))
