extends CharacterBody2D

@export var speed: float = 100.0
var direction := Vector2.RIGHT

var grid_size := Manager.grid_size
var cell_size := Manager.cell_size


func _ready():
	randomize()
	direction = pick_random_direction()
	

func _physics_process(delta):
	# Move enemy using collision detection
	var collision = move_and_collide(direction * speed * delta)
	check_exit_status()
	
	if collision:
		
		# Rotate randomly 90 degrees on wall collision
		if randf() < 0.5:
			direction = direction.rotated(deg_to_rad(90)).round()
		else:
			direction = direction.rotated(deg_to_rad(-90)).round()
		direction = pick_nearest_cardinal(direction)

func pick_random_direction() -> Vector2:
	var dirs = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	return dirs.pick_random()

func pick_nearest_cardinal(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)
	else:
		return Vector2(0, sign(vec.y))



func _on_player_damage_area_body_entered(body: Node2D) -> void:

	if not (body.is_in_group("wall") or body.is_in_group("orb") or body.is_in_group("enemy")):
		explode()




func explode():
	$explosion.emitting = true 
	await get_tree().create_timer($explosion.lifetime).timeout
	queue_free()



func check_exit_status():
	return
	var pos = global_position
	var max_coord = grid_size * cell_size
	
	if pos.x < 0 or pos.y < 0 or pos.x > max_coord or pos.y > max_coord:
		explode()
