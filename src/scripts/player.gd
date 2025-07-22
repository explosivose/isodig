
class_name Player extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/player.tscn")

static func create_player(pos: Vector3i) -> Player:
  var player: Player = PLAYER_SCENE.instantiate()
  player._place_in_world(pos)
  return player

signal try_move(player: Player, position: Vector3i, direction: Vector2i)
signal try_climb(player: Player, position: Vector3i)
signal try_descend(player: Player, position: Vector3i)
signal has_moved(player: Player, position: Vector3i)

var world_position: Vector3i
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var current_animation_prefix = "idle"

func _place_in_world(pos: Vector3i) -> void:
  world_position = pos

func _process(_delta: float) -> void:
  var mouse_pos = get_local_mouse_position() + Vector2.DOWN * 16
  # Rotate by 45 degrees for isometric view
  var angle = rad_to_deg(mouse_pos.angle()) + 45
  # Wrap angle to -180 to 180 range
  if angle > 180:
    angle -= 360
  elif angle < -180:
    angle += 360
  
  # Map angle to 8 directions aligned with isometric grid
  var direction = ""
  if angle >= -22.5 and angle < 22.5:
    direction = "ne"
  elif angle >= 22.5 and angle < 67.5:
    direction = "e"
  elif angle >= 67.5 and angle < 112.5:
    direction = "se"
  elif angle >= 112.5 and angle < 157.5:
    direction = "s"
  elif angle >= 157.5 or angle < -157.5:
    direction = "sw"
  elif angle >= -157.5 and angle < -112.5:
    direction = "w"
  elif angle >= -112.5 and angle < -67.5:
    direction = "nw"
  else:  # angle >= -67.5 and angle < -22.5
    direction = "n"
    
  sprite.play(current_animation_prefix + "_" + direction)

func _input(event: InputEvent) -> void:
  var move_intent = Vector2i.ZERO;
  if event.is_action_pressed("ui_left"):
    move_intent.x -= 1
  elif event.is_action_pressed("ui_right"):
    move_intent.x += 1
  elif event.is_action_pressed("ui_up"):
    move_intent.y -= 1
  elif event.is_action_pressed("ui_down"):
    move_intent.y += 1
  elif event.is_action_pressed("descend"):
    try_descend.emit(self)
  elif event.is_action_pressed("climb"):
    try_climb.emit(self)

  if move_intent != Vector2i.ZERO:
    print('move_intent', move_intent)
    current_animation_prefix = "walk"
    try_move.emit(self, world_position, move_intent)
  else:
    current_animation_prefix = "idle"
