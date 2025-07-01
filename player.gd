extends Node2D

class_name Player

signal try_move(player: Player, position: Vector3i, direction: Vector2i)

var world_position: Vector3i

func place_in_world(pos: Vector3i) -> void:
  world_position = pos

func _input(event: InputEvent) -> void:
  var move_intent = Vector2i.ZERO;
  if event.is_action_pressed("ui_left"):
    move_intent.x -= 1
  if event.is_action_pressed("ui_right"):
    move_intent.x += 1
  if event.is_action_pressed("ui_up"):
    move_intent.y -= 1
  if event.is_action_pressed("ui_down"):
    move_intent.y += 1
  if move_intent != Vector2i.ZERO:
    print('move_intent', move_intent)
    try_move.emit(self, world_position, move_intent)
