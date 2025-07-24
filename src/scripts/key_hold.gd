class_name KeyHold extends Timer

@export var hold_length: float = 0.5
@export var input_name: String

signal hold_threshold(input_name: String)
signal start_hold(input_name: String)
signal stop_hold(input_name: String)

func _init():
  autostart = false
  wait_time = hold_length
  one_shot = true
  timeout.connect(_hold_timeout)

func _hold_timeout():
  print(input_name, 'timeout')
  hold_threshold.emit(input_name)

func input(event: InputEvent):
  # Watch for keypress
  if event.is_action_pressed(input_name):
    print(input_name, 'start')
    start(hold_length)
    start_hold.emit(input_name)

  # Watch for keyrelease
  if event.is_action_released(input_name):
    stop()
    stop_hold.emit(input_name)
