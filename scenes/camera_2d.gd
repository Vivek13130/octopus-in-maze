extends Camera2D


@onready var player: Node2D = get_parent()  # Camera's parent is the player

# Zooming
var zoomTarget: Vector2
@export var zoomSpeed: float = 5

# Panning
@export var panSpeed: float = 2
var zoom_in_limit: int = 10
var isDragging: bool = false
var dragStartMousePos: Vector2
var dragStartCameraPos: Vector2
var zoom_level
var isDetached: bool = false  # Track if the camera is detached from the player

func _ready() -> void:
	zoomTarget = zoom

func _process(delta: float) -> void:
	simple_zoom(delta)
	pan_camera()

		# Press "C" to reset camera
	if Input.is_action_just_pressed("reset_camera"):
		reset_camera()

# Zooming function
func simple_zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *= 1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
	 
	zoomTarget.x = clamp(zoomTarget.x, 0.25, zoom_in_limit)
	zoomTarget.y = clamp(zoomTarget.y, 0.25, zoom_in_limit)
	
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	
	zoom_level = zoom

# Panning function (Right Click Drag)
func pan_camera():
	if Input.is_action_just_pressed("right_click"):  # Start drag
		isDragging = true
		dragStartMousePos = get_global_mouse_position()
		dragStartCameraPos = global_position

	if Input.is_action_pressed("right_click") and isDragging:  # Dragging
		var mouseDelta = get_global_mouse_position() - dragStartMousePos
		global_position = dragStartCameraPos - mouseDelta * panSpeed

	if Input.is_action_just_released("right_click"):  # Stop drag
		isDragging = false

# Reset Camera (Reattach to Player)
func reset_camera():
	isDetached = false
	position = Vector2.ZERO  # Reset to player's position
	zoom = Vector2(1, 1)  # Reset zoom if needed
