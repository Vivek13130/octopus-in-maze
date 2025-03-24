extends Control

@onready var text_edit: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/TextEdit
@onready var check_box: CheckBox = $CenterContainer/VBoxContainer/CheckBox
@onready var check_box_2: CheckBox = $CenterContainer/VBoxContainer/CheckBox2
@onready var button: Button = $CenterContainer/VBoxContainer/Button


func _on_button_pressed() -> void:
	var input_str = text_edit.text
	var input_val = input_str.to_int()

	if input_str.is_valid_int():
		input_val = clamp(input_val, Manager.min_grid_size, Manager.max_grid_size)
		Manager.grid_size = input_val
		print("Grid size set to:", Manager.grid_size)
	else:
		Manager.grid_size = 20
		print("Invalid integer input")
	
	Manager.leave_residue = check_box.button_pressed
	Manager.show_path_traveled = check_box_2.button_pressed
	
	
	Manager.path_of_player.clear()
	Manager.reached_exit = false
	Manager.total_time = 0.0
	# Reset any other states as needed

	var maze_scene = load("res://scenes/maze.tscn")
	get_tree().change_scene_to_packed(maze_scene)
