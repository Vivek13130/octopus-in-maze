extends Node


var cell_size : int
var grid_size : int
const min_grid_size = 3 
const max_grid_size = 50

var time_to_ui = -1
  
var show_path_traveled : bool = false 
var path_of_player := [] 
var reached_exit : bool = false 
var leave_residue : bool = false  
var player_grabbed_tile: bool = false  # Stores the currently grabbed tile


var total_time : float = 0

var enemy_list = []

# UI variables 
var two_digit_numbers : bool = false 
var numbers_blank : bool = false 
var operator_blank : bool = false 
var celebrated : bool = false 

var equations_dict : Dictionary = {}
var current_equation : Dictionary = {}
var counting_values_set := []
var correct_values := []
var correct_operators := []

var maze_complexity : float = 0.8
var equation_count : int = 3
var equation_solved : int = 0

var game_equation_scene: Node = null  # Reference to GameEquation scene

func load_next_equation(status:bool):
	if game_equation_scene:
		game_equation_scene.update_ui(status)
	else:
		print("❌ Error: GameEquation scene reference is missing!")


func can_we_free(string_num: String) -> bool:
	var is_number = string_num.is_valid_int()
	var num = string_num.to_int()

	# Check in the master correct list
	if is_number and correct_values.has(num) :
		print(string_num , "  value found in " , correct_values)
		return false
	elif !is_number and correct_operators.has(string_num) :
		print(string_num , "  opera found in " , correct_operators)
		return false
	
	
	print("deleted")
	return true


func free_values(string_num: String) -> void:
	var is_number = string_num.is_valid_int()
	var num = string_num.to_int()

	# If it's a number, remove it from correct number lists
	if is_number:
		Manager.correct_values.erase(num)
	else:
		# If it's an operator, remove from operator list
		Manager.correct_operators.erase(string_num)

	# Also remove from the global counting values set
	Manager.counting_values_set.erase(string_num)
	print("FREEE")



func clear_manager_state():
	# Reset grid-related variables
	reached_exit = false  
	player_grabbed_tile = false  
	
	# Reset time-related variables
	time_to_ui = -1
	total_time = 0
	
	# Reset gameplay variables
	show_path_traveled = false
	path_of_player.clear()
	leave_residue = false  
	enemy_list.clear()

	# Reset equation-related variables
	two_digit_numbers = false 
	numbers_blank = false 
	operator_blank = false 
	equations_dict.clear()
	current_equation.clear()
	counting_values_set.clear()
	correct_values.clear()
	correct_operators.clear()
	equation_solved = 0
	maze_complexity = 0.8 
	equation_count = 3  

	# Reset scene reference
	game_equation_scene = null
