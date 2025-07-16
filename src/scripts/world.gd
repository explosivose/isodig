# responsible for queries, mutations and side effects of world data

class_name World extends Node2D

const SIZE = 32
var X = SIZE
var Y = SIZE
var Z = 16

var world_data: PackedInt64Array
var world_view: WorldView
var nav: WorldNav


func _ready():
  nav = WorldNav.new(self)
  var player = Player.create_player(Vector3i(0, 0, Z - 1))
  player.try_move.connect(nav._try_move)
  player.try_climb.connect(nav._try_climb)
  player.try_descend.connect(nav._try_descend)


  world_data = PackedInt64Array()
  world_data.resize(X * Y * Z)
  world_data.fill(0)
  var noise = FastNoiseLite.new()
  noise.seed = randi()
  for x in range(X):
    for y in range(Y):
      for z in range(Z):
        var index = _get_index(x, y, z)
        if (z == Z - 1):
          # top layer 
          world_data[index] = 0
        else:
          # generate noise for the rest of the layers
          var value = noise.get_noise_3d(float(x) * 16, float(y) * 16, float(z) * 8)
          world_data[index] = 1 if value > -0.05 else 0

  world_view = WorldView.new(Vector3i(X, Y, Z))
  add_child(world_view)
  
  for x in range(X):
    for y in range(Y):
      for z in range(Z):
        var index = _get_index(x, y, z)
        var value = world_data[index]
        # if value == 1:
        #   world_view.paint_cell(Vector3i(x, y, z))
        world_view.autopaint_cell(Vector3i(x, y, z), value, get_neighbor_values(Vector3i(x, y, z)))
  
  world_view.get_layer(Z - 1).add_child(player)
  var camera = CameraControl.create_camera(player)
  get_tree().root.add_child.call_deferred(camera)

func _get_index(x: int, y: int, z: int) -> int:
  var index = x + y * X + z * X * Y
  if index < 0:
    return 0
  if index >= world_data.size():
    return world_data.size() - 1
  return index;

func _get_index_for_vector(pos: Vector3i) -> int:
  return _get_index(pos.x, pos.y, pos.z)

func set_block(pos: Vector3i, value: int) -> void:
  var index = _get_index_for_vector(pos)
  world_data[index] = value
  
func is_clear(pos: Vector3i) -> bool:
  var index = _get_index_for_vector(pos)
  return world_data[index] == 0

func is_block(pos: Vector3i) -> bool:
  var index = _get_index_for_vector(pos)
  return world_data[index] == 1

func get_neighbors_on_layer(pos: Vector3i) -> Array:
  var neighbors = []
  var directions = [
    Vector3i(1, 0, 0),
    Vector3i(-1, 0, 0),
    Vector3i(0, 1, 0),
    Vector3i(0, -1, 0),
    #Vector3i(0, 0, 1),
    #Vector3i(0, 0, -1)
  ]
  for dir in directions:
    neighbors.append(pos + dir)
  return neighbors

func get_neighbor_values(pos: Vector3i) -> Array[int]:
  var neighbors: Array[int] = [0, 0, 0, 0, 0, 0]
  var directions: Array[Vector3i] = [
    Vector3i(1, 0, 0),
    Vector3i(-1, 0, 0),
    Vector3i(0, 1, 0),
    Vector3i(0, -1, 0),
    Vector3i(0, 0, 1),
    Vector3i(0, 0, -1)
  ]
  for i in range(directions.size()):
    var dir = directions[i]
    var neighbor_pos = pos + dir
    if neighbor_pos.z >= 0 and neighbor_pos.z < Z:
      var world_data_index = _get_index_for_vector(neighbor_pos)
      neighbors[i] = world_data[world_data_index]
    else:
      neighbors[i] = 0 # Out of bounds, treat as empty
  return neighbors
