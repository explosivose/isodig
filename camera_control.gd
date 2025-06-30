extends Camera2D

const MOVE_SPEED = 100

const MIN_ZOOM = Vector2(0.5, 0.5)
const MAX_ZOOM = Vector2(1.5, 1.5)
const ZOOM_STEP = Vector2(0.25, 0.25)


func _physics_process(delta: float) -> void:
  if Input.is_action_pressed("ui_left"):
    position.x -= MOVE_SPEED * delta
  if Input.is_action_pressed("ui_right"):
    position.x += MOVE_SPEED * delta
  if Input.is_action_pressed("ui_up"):
    position.y -= MOVE_SPEED * delta
  if Input.is_action_pressed("ui_down"):
    position.y += MOVE_SPEED * delta

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("zoom_in"):
    zoom += ZOOM_STEP
  elif event.is_action_pressed("zoom_out"):
    zoom -= ZOOM_STEP
    
  zoom = zoom.clamp(MIN_ZOOM, MAX_ZOOM)
