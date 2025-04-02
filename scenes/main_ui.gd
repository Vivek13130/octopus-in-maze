extends Control

@onready var maze_size: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/maze_size
@onready var equation_count: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer2/equation_count
@onready var maze_complexity: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer3/maze_complexity



func _on_two_digit_numbers_pressed() -> void:
	Manager.two_digit_numbers = !Manager.two_digit_numbers


func _on_numbers_blank_pressed() -> void:
	Manager.numbers_blank = !Manager.numbers_blank


func _on_operator_blank_pressed() -> void:
	Manager.operator_blank = !Manager.operator_blank


func _on_play_button_pressed() -> void:
	# Set the maze size 
	var input_str = maze_size.text
	var input_val = input_str.to_int()

	if input_str.is_valid_int():
		input_val = clamp(input_val, Manager.min_grid_size, Manager.max_grid_size)
		Manager.grid_size = input_val
		print("Grid size set to:", Manager.grid_size)
	else:
		Manager.grid_size = 10
		print("Invalid integer input")
	
	# Set maze complexity 
	var maze_comp = maze_complexity.text.to_float()
	Manager.maze_complexity = maze_comp
	print("maze comp : " , maze_comp)
	
	# Set number of equations : 
	Manager.equation_count = equation_count.text.to_int()
	
	Manager.path_of_player.clear()
	Manager.reached_exit = false
	Manager.total_time = 0.0
	# Reset any other states as needed

	var maze_scene = load("res://scenes/maze.tscn")
	get_tree().change_scene_to_packed(maze_scene)
