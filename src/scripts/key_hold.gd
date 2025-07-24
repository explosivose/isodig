class_name KeyHold extends Timer

@export var hold_length: float = 0.5
@export var input_name: String

signal held(input_name: String)

func _init():
  autostart = false
  wait_time = hold_length
  one_shot = true
  timeout.connect(_hold_timeout)

func _hold_timeout():
  print('hold timeout')
  held.emit(input_name)

func input(event: InputEvent):
  # Watch for keypress
  if event.is_action_pressed(input_name):
    start(hold_length)

  # Watch for keyrelease
  if event.is_action_released(input_name):
    stop()
