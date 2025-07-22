""" responsible for rendering a single layer of the world """

"""
Tiling rules:
  Z+1 Y+1 X+1 Z-1 Y-1 X-1
   0   0   0   ?   ?   ?  ABC
   0   0   x   ?   ?   ?  AB
   0   x   0   ?   ?   ?  AC
   x   0   0   ?   ?   ?  BC
   x   0   x   ?   ?   ?  B
   x   x   0   ?   ?   ?  C
   0   x   x   ?   ?   ?  A
   x   x   x   ?   ?   ?  noop
   ?   0   x   x   x   x  EFG
   ?   x   0   x   x   x  EFG
"""

class_name WorldLayer extends TileMapLayer

const ATLAS_ID = 0
const TILE_ABC = Vector2i(0, 0)
const TILE_AB = Vector2i(0, 3)
const TILE_AC = Vector2i(3, 2)
const TILE_BC = Vector2i(1, 3)
const TILE_A = Vector2i(2, 2)
const TILE_AX = Vector2i(2, 4)
const TILE_B = Vector2i(3, 3)
const TILE_C = Vector2i(2, 3)
const TILE_EFG = Vector2i(1, 2)
# const TILE_ABC = Vector2i(0, 0)
# const TILE_AB = Vector2i(0, 1)
# const TILE_AC = Vector2i(3, 0)
# const TILE_BC = Vector2i(1, 1)
# const TILE_A = Vector2i(2, 0)
# const TILE_B = Vector2i(3, 1)
# const TILE_C = Vector2i(2, 1)
# const TILE_EFG = Vector2i(1, 0)
var depth = 0

# a random light color
static var color_a = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0))
# the complementary of color_a
static var color_b = Color.from_hsv(fmod(color_a.h + 0.5, 1.0), color_a.s, color_a.v)

func set_depth(new_depth: int, max_depth: int) -> void:
  depth = new_depth
  # alternatate between two colors based on depth
  var color = color_a if depth % 2 == 0 else color_b
  var layer_color = color.lerp(color.darkened(0.35), 1 - float(depth) / max_depth)
  self_modulate = layer_color
 
func set_transparent(transparent: bool) -> void:
  self_modulate.a = 0.5 if transparent else 1.0

# xyz
# [(-1, -1, -1), (-1, -1, 0), (-1, -1, 1), (-1, 0, -1), (-1, 0, 0), (-1, 0, 1), (-1, 1, -1), (-1, 1, 0), (-1, 1, 1), (0, -1, -1), (0, -1, 0), (0, -1, 1), (0, 0, -1), (0, 0, 1), (0, 1, -1), (0, 1, 0), (0, 1, 1), (1, -1, -1), (1, -1, 0), (1, -1, 1), (1, 0, -1), (1, 0, 0), (1, 0, 1), (1, 1, -1), (1, 1, 0), (1, 1, 1)]
#                                 0, 1, 2, 3, 4, 5
# expects values in this order: [+X,-X,+Y,-Y,+Z,-Z]
# TODO test this, then write automated tests
func autopaint_cell(coords: Vector2i, value: int, neighbor_values: Array[int]) -> void:
  if value != 0:
    match neighbor_values:
      [var x, _, var y, _, var z, _] when x != 0 and y != 0 and z == 0:
        paint_cell(coords, TILE_A)
      [var x, _, var y, _, var z, _] when x != 0 and y != 0 and z != 0:
        paint_cell(coords, TILE_AX)
      [var x, _, var y, _, var z, _] when x != 0 and y == 0 and z != 0:
        paint_cell(coords, TILE_B)
      [var x, _, var y, _, var z, _] when x == 0 and y != 0 and z != 0:
        paint_cell(coords, TILE_C)
      [var x, _, var y, _, var z, _] when x != 0 and y == 0 and z == 0:
        paint_cell(coords, TILE_AB)
      [var x, _, var y, _, var z, _] when x == 0 and y != 0 and z == 0:
        paint_cell(coords, TILE_AC)
      [var x, _, var y, _, var z, _] when x == 0 and y == 0 and z != 0:
        paint_cell(coords, TILE_BC)
      [var x, _, var y, _, var z, _] when x == 0 and y == 0 and z == 0:
        paint_cell(coords, TILE_ABC)
      _:
        print_debug("no match", coords, value, neighbor_values)
        paint_cell(coords)

func paint_cell(coords: Vector2i, tile = TILE_ABC) -> void:
  set_cell(coords, ATLAS_ID, tile)


# func _input(event: InputEvent) -> void:
#   if event is InputEventMouseMotion:
#     var camera = get_viewport().get_camera_2d()
#     var coords = local_to_map(camera.get_global_mouse_position())
#     paint_cell(coords)
