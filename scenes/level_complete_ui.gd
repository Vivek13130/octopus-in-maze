extends Control

@onready var info: RichTextLabel = $MarginContainer/VBoxContainer/info


var performance_texts := [
	"[color=green]Wow![/color]",
	"[color=green]Well done![/color]",
	"[color=blue]Great job![/color]",
	"[color=orange]Keep going![/color]",
	"[color=purple]You're ahead of 90% players![/color]",
	"[color=purple]Top 5% performance![/color]",
	"[color=green]Speedrun level![/color]",
	"[color=red]You can do better![/color]",
	"[color=red]You performed poorly.[/color]",
	"[color=orange]Average performance.[/color]",
	"[color=green]Impressive focus![/color]",
	"[color=blue]Smart solving![/color]",
	"[color=cyan]Good effort![/color]",
	"[color=magenta]You crushed it![/color]",
	"[color=darkorange]Try to improve![/color]"
]
func _ready() -> void:
	var time_taken = Manager.total_time_taken  # e.g., "Time : 01:23"
	var equation_solved = Manager.equation_count

	var formatted_time = format_time_string(time_taken)
	display_performance(formatted_time, equation_solved)
	$level_comp.play()

func display_performance(time_taken: String, equations_solved: int) -> void:
	var random_feedback = performance_texts.pick_random()
	var final_text := "You took [color=yellow]%s[/color] to solve [color=cyan]%d equations[/color].\n%s" % [time_taken, equations_solved, random_feedback]
	info.text = final_text



func format_time_string(raw_time: String) -> String:
	print("formatting time : ", raw_time)

	# Extract only the digits from the end of the string
	var parts = raw_time.strip_edges().split(":")
	if parts.size() >= 2:
		var minutes = parts[parts.size() - 2]
		var seconds = parts[parts.size() - 1]
		return "%s Min %s Sec" % [minutes, seconds]
	else:
		return "00 Min 00 Sec"




func _on_play_again_pressed() -> void:
	Manager.reached_exit = false
	Manager.equation_solved = 0
	Manager.player_grabbed_tile = false  
	
	# Reset time-related variables
	Manager.time_to_ui = -1
	Manager.total_time = 0
	
	# Reset gameplay variables
	Manager.show_path_traveled = false
	Manager.path_of_player.clear()
	Manager.equations_dict.clear()
	Manager.current_equation.clear()
	Manager.counting_values_set.clear()
	Manager.correct_values.clear()
	Manager.correct_operators.clear()
	
	var maze_scene = load("res://scenes/maze.tscn")
	get_tree().change_scene_to_packed(maze_scene)


func _on_main_menu_pressed() -> void:
	Manager.clear_manager_state()

	var main_menu_scene = load("res://scenes/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu_scene)
	
