extends Control

var two_digit_numbers: bool = false
var missing_number: bool = false
var missing_operator: bool = false
var equation_count: int = 5
var equations_dict = {}  # Dictionary to store indexed equations

var current_equation_ind : int =  0
@onready var celebration_particles: CPUParticles2D = $main_strip/celebrationParticles


@onready var num1_label: Label = $main_strip/GridContainer/num1/Label
@onready var op_label: Label = $main_strip/GridContainer/operator/Label
@onready var num2_label: Label = $main_strip/GridContainer/num2/Label
@onready var result_label: Label = $main_strip/GridContainer/result/Label

@onready var timer: Label = $bottom_strip/HBoxContainer/timer
@onready var equation_solved: Label = $bottom_strip/HBoxContainer/equation_solved
@onready var status: Label = $bottom_strip/HBoxContainer/status
@onready var correct: PanelContainer = $main_strip/GridContainer/correct
@onready var incorrect: PanelContainer = $main_strip/GridContainer/incorrect


@export var empty_style : StyleBox = preload("res://scenes/empty_equation_box.tres")
@export var filled_style : StyleBox = preload("res://scenes/equation_box.tres")


var operators = ["+", "-", "X", "/"]
var values_set = []  # Stores correct & incorrect values for maze

func _ready() -> void:
	Manager.game_equation_scene = self  # Set reference to the current instance
	two_digit_numbers = Manager.two_digit_numbers
	missing_number = Manager.numbers_blank
	missing_operator = Manager.operator_blank
	equation_count = Manager.equation_count
	generate_equations()

var time_consumed : float = 0.0

func _process(delta: float) -> void:
	update_status_label()
	
	if(!Manager.reached_exit):
		time_consumed += delta
	else:
		if(status.visible == false):
			status.visible = true
		
	
	# Convert time to minutes and seconds
	var minutes = int(time_consumed) / 60
	var seconds = int(time_consumed) % 60
	
	# Update timer label
	timer.text = "Time: %02d:%02d" % [minutes, seconds]
	
	# Update solved equations count
	equation_solved.text = "Solved: %d / %d" % [Manager.equation_solved, Manager.equation_count]
	

func update_status_label() -> void:
	if(Manager.time_to_ui != -1):
		status.text = "You solved all equations in: " + str(int(time_consumed)) + "s.\n" + "Heading Back to main menu in " + str(int(Manager.time_to_ui)) + "s ..."


func generate_equations() -> void:
	values_set.clear()
	var operator_set = []  

	print("\n--- Generating Equations ---")

	var i = 0  # Manual counter to ensure exact `equation_count`
	while i < equation_count:
		var op = operators.pick_random()
		var a = get_random_number()
		var b = get_random_number()
		var result = calculate(a, b, op)

		if result == null:  # If invalid equation, retry without increasing `i`
			continue

		var num1_text = str(a)
		var op_text = op
		var num2_text = str(b)
		var result_text = str(result)
		var missing_part = ""

		# Randomly decide if this equation will have a missing number or missing operator
		var make_missing_number = missing_number and missing_operator and (randi() % 2 == 0)
		var make_missing_operator = missing_number and missing_operator and !make_missing_number
		make_missing_number = make_missing_number or (missing_number and !missing_operator)
		make_missing_operator = make_missing_operator or (!missing_number and missing_operator)

		if make_missing_number:
			match randi() % 3:
				0:
					num1_text = "?"
					values_set.append(a)
					missing_part = "num1"
				1:
					num2_text = "?"
					values_set.append(b)
					missing_part = "num2"
				2:
					result_text = "?"
					values_set.append(result)
					missing_part = "result"

		elif make_missing_operator:
			op_text = "?"
			operator_set.append(op)
			missing_part = "operator"

		# Store the equation in a dictionary with index as key
		equations_dict[i] = {
			"num1": num1_text,
			"operator": op_text,
			"num2": num2_text,
			"result": result_text,
			"missing_part": missing_part,
			"correct_value": a if missing_part == "num1" else b if missing_part == "num2" else result if missing_part == "result" else op
		}

		print("Equation %d: %s %s %s = %s (Missing: %s)" % [i+1, num1_text, op_text, num2_text, result_text, missing_part])

		i += 1  # Increase counter only for valid equations
	
	Manager.correct_values = values_set.duplicate()
	Manager.correct_operators = operator_set.duplicate()
	print("Correct values:", values_set)
	print("Correct operators:", operator_set)
	Manager.equations_dict = equations_dict  # Store the dictionary in Manager
	
	var grid_size = Manager.grid_size
	var multip = 2 
	if missing_number and missing_operator:
		multip = 1

	# Determine the base count from equation count and grid size
	var total_tiles_needed = max(equation_count * multip, grid_size * grid_size / 24) # Adjust divisor for density

	# Add incorrect values to the maze
	if missing_number:
		while values_set.size() < total_tiles_needed:
			values_set.append(get_random_number())

	if missing_operator:
		while operator_set.size() < total_tiles_needed:
			operator_set.append(operators.pick_random())

		operator_set.shuffle()
		values_set.append_array(operator_set)

	values_set.shuffle()
	print("\nCorrect + Random Values for Maze:", values_set)
	Manager.counting_values_set = values_set

	
	load_next_equation()

func get_random_number() -> int:
	if two_digit_numbers:
		return randi_range(10, 99)
	return randi_range(1, 9)

func calculate(a: int, b: int, op: String):
	match op:
		"+": return a + b
		"-": return a - b if a >= b else null  # Ensure non-negative results
		"*": return a * b
		"/": return a / b if b != 0 and a % b == 0 else null  # Ensure valid division
	return null

func update_ui(status : bool) -> void:
	if(status):
		correct.visible = true 
	
			
		var prev_eq = Manager.current_equation
		if not prev_eq.is_empty():
			var label_to_grow: Label
			var panel_to_style: Control
			var value_to_fill = str(prev_eq["correct_value"])

			# Identify which field had "?"
			if prev_eq["num1"] == "?":
				label_to_grow = num1_label
			elif prev_eq["num2"] == "?":
				label_to_grow = num2_label
			elif prev_eq["operator"] == "?":
				label_to_grow = op_label
			elif prev_eq["result"] == "?":
				label_to_grow = result_label

			if label_to_grow:
				panel_to_style = label_to_grow.get_parent()
				label_to_grow.text = value_to_fill
				panel_to_style.add_theme_stylebox_override("panel", load("res://scenes/equation_box.tres"))

				# Get the current font size and set it to a small value first
				var font_size = label_to_grow.get_theme_font_size("font_size")
				label_to_grow.add_theme_font_size_override("font_size", 10)  # Start small

				# Create a tween to smoothly increase the font size
				var tween = create_tween()
				tween.tween_method(
					func(size): label_to_grow.add_theme_font_size_override("font_size", size),
					60, font_size, 0.8
				)

				# Move and trigger particles
				celebration_particles.global_position = label_to_grow.global_position + Vector2(40, 40)
				celebration_particles.emitting = true
	else:
		incorrect.visible = true 
		
	$next_equation.start()
	



func load_next_equation():
	
	if equations_dict.is_empty() || !equations_dict.has(current_equation_ind):
		print("!!!! current equation is not valid")
		return
	
	
	print("total equations : ", equation_count)
	print("updating for index : ", current_equation_ind)

	var first_eq = equations_dict[current_equation_ind]

	# Update labels
	num1_label.text = first_eq["num1"]
	op_label.text = first_eq["operator"]
	num2_label.text = first_eq["num2"]
	result_label.text = first_eq["result"]

	# Get parent containers of each label
	var num1_panel = num1_label.get_parent()
	var op_panel = op_label.get_parent()
	var num2_panel = num2_label.get_parent()
	var result_panel = result_label.get_parent()

	# Apply styles based on whether the value is missing ("?")
	num1_panel.add_theme_stylebox_override("panel", empty_style if first_eq["num1"] == "?" else filled_style)
	op_panel.add_theme_stylebox_override("panel", empty_style if first_eq["operator"] == "?" else filled_style)
	num2_panel.add_theme_stylebox_override("panel", empty_style if first_eq["num2"] == "?" else filled_style)
	result_panel.add_theme_stylebox_override("panel", empty_style if first_eq["result"] == "?" else filled_style)

	# Store current equation for answer checking
	Manager.current_equation = first_eq
	current_equation_ind += 1


func _on_next_equation_timeout() -> void:
	if(correct.visible):
		load_next_equation()
	
	correct.visible = false 
	incorrect.visible = false
