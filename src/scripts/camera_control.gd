extends Camera2D

const MOVE_SPEED = 100

const MIN_ZOOM = Vector2(0.5, 0.5)
const MAX_ZOOM = Vector2(1.5, 1.5)
const ZOOM_STEP = Vector2(0.25, 0.25)

# the target for the camera to follow (editable in the editor)
@export var target: Node2D

func _ready() -> void:
  if target:
    position = target.position
  zoom = Vector2(1, 1)
  make_current()

func _physics_process(delta: float) -> void:
  if target:
    position = lerp(position, target.position, 0.1)

func _input(event: InputEvent) -> void:
  make_current()
  if event.is_action_pressed("zoom_in"):
    zoom += ZOOM_STEP
  elif event.is_action_pressed("zoom_out"):
    zoom -= ZOOM_STEP
    
  zoom = zoom.clamp(MIN_ZOOM, MAX_ZOOM)
