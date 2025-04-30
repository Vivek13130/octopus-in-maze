extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_up_level(numbers_blank , operator_blank, maze_complexity, 
equation_count, grid_size):
	Manager.numbers_blank = numbers_blank
	Manager.operator_blank = operator_blank
	Manager.maze_complexity = maze_complexity
	Manager.equation_count = equation_count
	Manager.grid_size = grid_size
	
	Manager.reached_exit = false
	Manager.total_time = 0.0
	
	var maze_scene = load("res://scenes/maze.tscn")
	get_tree().change_scene_to_packed(maze_scene)

func _on_easy_button_pressed() -> void:
	set_up_level(true,false,0.8, 2, 4)
	$button_click.play()

func _on_medium_button_pressed() -> void:
	set_up_level(true, false, 0.7, 4, 6)
	$button_click.play()
	

func _on_hard_button_pressed() -> void:
	set_up_level(true, true, 0.9, 7, 8)
	$button_click.play()
	
