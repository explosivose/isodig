extends Camera2D

const MOVE_SPEED = 100

const MIN_ZOOM = Vector2(0.5, 0.5)
const MAX_ZOOM = Vector2(1.5, 1.5)
const ZOOM_STEP = Vector2(0.25, 0.25)

@export var target: Player

func _physics_process(delta: float) -> void:
  var move_to = target.position
  move_to.y -= -2 * 16 + target.world_position.z * 16
  position = lerp(position, move_to, 0.1)

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("zoom_in"):
    zoom += ZOOM_STEP
  elif event.is_action_pressed("zoom_out"):
    zoom -= ZOOM_STEP
    
  zoom = zoom.clamp(MIN_ZOOM, MAX_ZOOM)
