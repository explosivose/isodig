extends Node2D

var X = 8
var Y = 16
var Z = 16

var world_data: PackedInt64Array
const WorldLayerScene = preload("res://world_layer.tscn")

func _ready():
  world_data = PackedInt64Array()
  world_data.resize(X * Y * Z)
  world_data.fill(0)
  for x in range(X):
    for y in range(Y):
      for z in range(Z):
        var index = x + y * X + z * X * Y;
        world_data[index] = 1 if randf() > 0.25 else 0

  for z in range(Z):
    var layer = WorldLayerScene.instantiate()
    layer.name = "layer_%d" % z
    layer.position = Vector2(0, -z * 16)
    layer.set_depth(z, Z)
    for x in range(X):
      for y in range(Y):
        var index = x + y * X + z * X * Y;
        var value = world_data[index]
        if (value == 1):
          layer.paint_cell(Vector2i(x, y))
    add_child(layer)
