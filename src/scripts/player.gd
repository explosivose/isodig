class_name Player extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/player.tscn")

enum MODE {
  DIG,
  FILL
}

static func create_player(pos: Vector3i) -> Player:
  var player: Player = PLAYER_SCENE.instantiate()
  player.has_moved.connect(player.player_moved)
  player._place_in_world(pos)
  return player

signal try_move(player: Player, position: Vector3i, direction: Vector2i)
signal try_climb(player: Player, position: Vector3i)
signal try_descend(player: Player, position: Vector3i)
signal has_moved(player: Player, position: Vector3i)
signal try_dig(position: Vector3i)
signal try_fill(position: Vector3i)

var world_position: Vector3i
var _current_animation_prefix = "idle"
var _mode = MODE.DIG

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _input_movement_hold_timers: Array[KeyHold] = [
  $KeyHoldUp,
  $KeyHoldDown,
  $KeyHoldLeft,
  $KeyHoldRight
]

func _place_in_world(pos: Vector3i) -> void:
  world_position = pos

func _ready():
  _init_hold_inputs()

func _init_hold_inputs():
  for timer in _input_movement_hold_timers:
    timer.held.connect(_on_hold_movement)

func player_moved(_arg, _arg2):
  for timer in _input_movement_hold_timers:
    timer.stop()

func _input(event: InputEvent) -> void:
  for timer in _input_movement_hold_timers:
    timer.input(event)
  var _move_intent = Vector3i.ZERO;
  if event.is_action_pressed("set_mode_dig"):
    _mode = MODE.DIG
  elif event.is_action_pressed("set_mode_fill"):
    _mode = MODE.FILL
  elif event.is_action_pressed("ui_left"):
    _move_intent.x -= 1
  elif event.is_action_pressed("ui_right"):
    _move_intent.x += 1
  elif event.is_action_pressed("ui_up"):
    _move_intent.y -= 1
  elif event.is_action_pressed("ui_down"):
    _move_intent.y += 1
  elif event.is_action_pressed("descend"):
    _move_intent.z -= 1
    try_descend.emit(self)
  elif event.is_action_pressed("climb"):
    try_climb.emit(self)
    _move_intent.z += 1

  if _move_intent != Vector3i.ZERO:
    _set_anim_direction(_move_intent)
    _current_animation_prefix = "walk"
    try_move.emit(self, world_position, _move_intent)
  else:
    _current_animation_prefix = "idle"

func _set_anim_direction(move_intent: Vector3i):
  var anim_direction = ""
  if move_intent.x > 0:
    anim_direction = "se"
  elif move_intent.x < 0:
    anim_direction = "nw"
  elif move_intent.y > 0:
    anim_direction = "sw"
  elif move_intent.y < 0:
    anim_direction = "ne"

  sprite.play(_current_animation_prefix + "_" + anim_direction)

func _on_hold_movement(input_name: String):
  var _intent = Vector3i.ZERO
  if input_name == "ui_left":
    _intent.x -= 1
  elif input_name == "ui_right":
    _intent.x += 1
  elif input_name == "ui_up":
    _intent.y -= 1
  elif input_name == "ui_down":
    _intent.y += 1
  elif input_name == "descend":
    _intent.z -= 1
  elif input_name == "climb":
    _intent.z += 1
  if _mode == MODE.DIG:
    try_dig.emit(world_position + _intent)
  elif _mode == MODE.FILL:
    try_fill.emit(world_position)
    try_move.emit(self, world_position, -_intent)
