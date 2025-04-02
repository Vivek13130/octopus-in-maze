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

var equations_dict : Dictionary = {}
var current_equation : Dictionary = {}
var counting_values_set := []
var correct_values_operators := []

var maze_complexity : float = 0.2
var equation_count : int = 3
var equation_solved : int = 0

var game_equation_scene: Node = null  # Reference to GameEquation scene

func load_next_equation():
	if game_equation_scene:
		game_equation_scene.update_ui()
	else:
		print("❌ Error: GameEquation scene reference is missing!")


func can_we_free(string_num: String) -> bool:
	# Try converting to an integer
	var num = string_num.to_int()
	
	# Check if it's a valid number or an operator
	var is_number = string_num.is_valid_int()

	# Search in the correct values/operators list
	if is_number and correct_values_operators.has(num):
		return false
	elif !is_number and correct_values_operators.has(string_num):
		return false
	
	return true
