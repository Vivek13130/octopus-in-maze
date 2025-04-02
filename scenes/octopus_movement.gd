extends CharacterBody2D

const SPEED = 300.0
const GRAVITY = 800.0
@export var residue_interval := 0.5

@export var residue_scene : PackedScene
var residue_container 
var prev_residue_pos : Vector2

@export var residue_dist_threshold : int = 50


var path_points: Array = []

	

func _ready() -> void:
	$residueTimer.wait_time = residue_interval 
	var maze_node = get_tree().get_current_scene()
	residue_container = maze_node.get_node("residueContainer")


# constant speed movement 
func _physics_process(delta: float) -> void:
	if(Manager.reached_exit):
		return # stop movement
	
	velocity.y += GRAVITY * delta
	
	# store position at certain intervals or when moved enough
	if Manager.path_of_player.is_empty() or Manager.path_of_player[-1].distance_to(global_position) > 20.0:
		Manager.path_of_player.append(global_position)
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	
	# Allow upward movement against gravity
	if input_vector.y != 0:
		velocity.y = input_vector.y * SPEED
	
	# Horizontal movement
	velocity.x = input_vector.x * SPEED
	
	move_and_slide()
	




func take_damage():
	screen_shake()

func screen_shake():
	var tween = create_tween()
	tween.tween_property(get_tree().current_scene, "position", Vector2(20, 20), 0.05)
	tween.tween_property(get_tree().current_scene, "position", Vector2(-20, -20), 0.05)
	tween.tween_property(get_tree().current_scene, "position", Vector2(20, 20), 0.05)
	tween.tween_property(get_tree().current_scene, "position", Vector2(-20, -20), 0.05)
	tween.tween_property(get_tree().current_scene, "position", Vector2(0, 0), 0.05)

func _on_residue_timer_timeout() -> void:
	if(Manager.leave_residue):
		if(global_position.distance_to(prev_residue_pos) >= residue_dist_threshold):
			var residue = residue_scene.instantiate()
			residue.global_position = global_position
			if(residue_container):
				residue_container.add_child(residue)
				prev_residue_pos = global_position
			else :
				print("no container found ")
