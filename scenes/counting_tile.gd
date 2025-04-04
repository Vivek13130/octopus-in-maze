extends StaticBody2D

@onready var counting_value: Label = $PanelContainer/counting_value
@onready var point_light: PointLight2D = $PointLight2D
@onready var celebrate: CPUParticles2D = $celebrate
@onready var sad: CPUParticles2D = $sad

var player: Node2D = null
var is_following: bool = false
@onready var start_blinking: Timer = $start_blinking

func _ready() -> void:
	var random_time = randf_range(0, 3.0)
	start_blinking.wait_time = random_time
	#start_blinking.start()


func _process(delta):
	if is_following and player:
		global_position = global_position.lerp(player.global_position, 0.1)  # Smooth follow

func _on_picking_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !is_following:
		player = body
		point_light.color = Color.DEEP_SKY_BLUE
		point_light.blend_mode = Light2D.BLEND_MODE_MIX
		point_light.enabled = true

func _on_picking_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and !is_following:
		player = null
		point_light.enabled = false

func _input(event):
	if event.is_action_pressed("pick_tile") and player:
		# If trying to pick up a tile and another tile is already grabbed, do nothing
		if !is_following and Manager.player_grabbed_tile:
			return  

		is_following = !is_following  # Toggle following state

		if is_following:
			Manager.player_grabbed_tile = true  # Store the grabbed tile
			point_light.color = Color(1, 0.32, 1)
			point_light.blend_mode = Light2D.BLEND_MODE_ADD
		else:
			Manager.player_grabbed_tile = false  # Release tile
			player = null
			check_exit_status()  # Check if the tile is in the exit area

func check_exit_status():
	var grid_size = Manager.grid_size
	var cell_size = Manager.cell_size
	
	print("grid size : ", grid_size)
	print("cell size : ", cell_size)
	# Define the exit box region
	var exit_x = (grid_size - 1)* cell_size 
	var exit_y = (grid_size - 1)* cell_size 
	
	print("Exit pos : ", Vector2(exit_x,exit_y))
	
	# Check if the tile is in the exit area
	if global_position.x > exit_x and global_position.y > exit_y:
		print("Tile dropped in exit box!")
		validate_equation()
	else:
		print("Tile dropped outside exit box.")
		print("tile pos : " , global_position)



func validate_equation():
	var tile_value = counting_value.text

	# Ensure there's an active equation
	if not Manager.current_equation.has("correct_value"):
		print("⚠️ No active equation to validate!")
		return

	# Check if the tile value matches the correct missing value
	if tile_value == str(Manager.current_equation["correct_value"]):
		print("✅ Correct Answer!")
		Manager.equation_solved += 1
		screen_shake_correct()
		celebrate.emitting = true
		Manager.load_next_equation(true)
		Manager.free_values(tile_value)
	else:
		print("❌ Wrong Answer!")
		Manager.load_next_equation(false)
		screen_shake_wrong()
		shake_tile()
		sad.emitting = true




func screen_shake_correct():
	var scene = get_tree().current_scene
	var tween = create_tween()
	tween.tween_property(scene, "position", Vector2(10, -10), 0.05)
	tween.tween_property(scene, "position", Vector2(-10, 10), 0.05)
	tween.tween_property(scene, "position", Vector2(0, 0), 0.05)

func screen_shake_wrong():
	var scene = get_tree().current_scene
	var tween = create_tween()
	tween.tween_property(scene, "position", Vector2(20, 20), 0.03)
	tween.tween_property(scene, "position", Vector2(-25, -15), 0.03)
	tween.tween_property(scene, "position", Vector2(15, -20), 0.03)
	tween.tween_property(scene, "position", Vector2(-20, 25), 0.03)
	tween.tween_property(scene, "position", Vector2(0, 0), 0.03)


func shake_tile():
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 40, 0.05)
	tween.tween_property(self, "position:x", position.x - 40, 0.05)
	tween.tween_property(self, "position:x", position.x + 40, 0.05)
	tween.tween_property(self, "position:x", position.x - 40, 0.05)
	tween.tween_property(self, "position:x", position.x + 40, 0.05)
	tween.tween_property(self, "position:x", position.x - 40, 0.05)
	tween.tween_property(self, "position:x", position.x, 0.05)


func particles_finished() -> void:
	var val = counting_value.text

	if Manager.can_we_free(val):
		queue_free()
		Manager.free_values(val)
	else:
		print("spawned again !!!!!!")
		position = get_random_grid_position()


func get_random_grid_position() -> Vector2:
	var grid_size = Manager.grid_size
	var cell_size = Manager.cell_size
	var random_x = randi_range(0, grid_size - 1)
	var random_y = randi_range(0, grid_size - 1)
	return Vector2((random_x + 0.5) * cell_size, (random_y + 0.5) * cell_size)

@onready var blinking_light: PointLight2D = $blinking_light
@onready var blink_timer: Timer = $blink_timer

func _on_blink_timer_timeout() -> void:
	if(is_following):
		blinking_light.enabled = false 
		return 
	 
	blinking_light.enabled = !blinking_light.enabled
	if(blinking_light.enabled):
		blink_timer.wait_time = 0.1
	else:
		blink_timer.wait_time = 4
	blink_timer.start()


func _on_start_blinking_timeout() -> void:
	blink_timer.autostart = true
	blink_timer.start()
