extends Camera2D
#Responsibility : 
#control zoom in and out with limits
#panning via w , a , s, d
#click and drag

@export var updateCanvasDynamically = false 

@onready var canvas_container: Node2D = $".."
@onready var stroke_manager: Node2D = $"../strokeManager"

#const zoom_in_limit = 2 * 10e7

# zooming : 
var zoomTarget : Vector2
@export var zoomSpeed : float = 5

# panning : 
@export var panSpeed : int = 2

# click and drag : 
var dragStartMousePos : Vector2
var dragStartCameraPos : Vector2
var isDragging : bool = false 
var zoom_level

func _ready() -> void:
	zoomTarget = zoom

func _process(delta: float) -> void:
	simple_zoom(delta)


func simple_zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *= 1.1
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
	
	#zoomTarget.x = clamp(zoomTarget.x, 0 , zoom_in_limit)
	#zoomTarget.y = clamp(zoomTarget.y, 0 , zoom_in_limit)
	
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)
	if updateCanvasDynamically:
		stroke_manager.queue_redraw()
	
	zoom_level = zoom
