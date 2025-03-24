extends Node2D

var grid_size = Manager.grid_size
@export var cell_size: int = 120


@export var player_scene: PackedScene
@onready var player_container := $playerContainer 

@export var wall_thickness: float = 1.0
@onready var maze_walls_container: Node2D = $mazeWallsContainer
@export var overlap_size: float = 20.0

@export var spawn_box_size: int = 200
@export var exit_box_size: int = 200
@onready var head_to_ui: Timer = $headToUI
@onready var time_taken: Label = $CanvasLayer/Control/VBoxContainer/TimeTaken

@onready var center_container: CenterContainer = $CanvasLayer/Control/CenterContainer
@onready var show_total_time: Label = $"CanvasLayer/Control/CenterContainer/VBoxContainer/show total time"
@onready var heading_back: Label = $"CanvasLayer/Control/CenterContainer/VBoxContainer/heading back"


class Cell:
	var visited = false
	var walls = { "top": true, "right": true, "bottom": true, "left": true }

var maze = []
var stack = []
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var player 
var player_body 

func _ready():
	spawn_player()
	generate_maze()
	convert_maze_to_walls()

func _process(delta: float) -> void:
	if(!Manager.reached_exit) : 
		Manager.total_time  += delta
	
	if(Manager.reached_exit and !center_container.visible ):
		center_container.visible = true 
		show_total_time.text = "You took " + format_time(Manager.total_time) + " to get out !"
		heading_back.text = "Heading back to Main Menu..."
	
	if center_container.visible:
		var time_remaining = int($headToUI.time_left)
		heading_back.text = "Heading back to Main Menu in " + str(time_remaining) + "s..."

	
	time_taken.text = format_time(Manager.total_time)
	check_exit_status()
	if(Manager.show_path_traveled):
		$Line2D.points = Manager.path_of_player

func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func check_exit_status():
	if player_body == null :
		return
	
	var cell_x = int(player_body.global_position.x / cell_size)
	var cell_y = int(player_body.global_position.y / cell_size)
	if cell_x == grid_size - 1 and cell_y == grid_size - 1 and !Manager.reached_exit:
		Manager.reached_exit = true
		$Line2D.points = Manager.path_of_player
		$residueContainer.visible = false
		head_to_ui.start()
		print("timer started")


func spawn_player():
	print("player spawned")
	player = player_scene.instantiate()
	player_body = player.get_child(2)
	# Position player in the center of the spawn box (top-left)
	var spawn_box_center = Vector2(cell_size/2, -cell_size )  # since spawn box will be placed at top-left
	player.global_position = spawn_box_center
	print(player.global_position)
	
	player_container.add_child(player)


func spawn_spawn_box():
	var spawn_box = StaticBody2D.new()
	spawn_box.position = Vector2(-overlap_size, -overlap_size)
	
	var collider = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(spawn_box_size, spawn_box_size)
	collider.shape = shape
	collider.position = shape.size / 2.0
	spawn_box.add_child(collider)
	
	var color_rect = ColorRect.new()
	color_rect.color = Color.DARK_GREEN
	color_rect.size = shape.size
	color_rect.position = Vector2.ZERO
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spawn_box.add_child(color_rect)
	
	maze_walls_container.add_child(spawn_box)

func spawn_exit_box():
	var exit_box = StaticBody2D.new()
	exit_box.position = Vector2((grid_size - 1) * cell_size - (exit_box_size - cell_size / 2), (grid_size - 1) * cell_size - (exit_box_size - cell_size / 2))
	
	var collider = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(exit_box_size, exit_box_size)
	collider.shape = shape
	collider.position = shape.size / 2.0
	exit_box.add_child(collider)
	
	var color_rect = ColorRect.new()
	color_rect.color = Color.DARK_RED
	color_rect.size = shape.size
	color_rect.position = Vector2.ZERO
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	exit_box.add_child(color_rect)
	
	maze_walls_container.add_child(exit_box)



# generating maze by backtracking
func generate_maze():
	maze.clear()
	stack.clear()
	
	for x in range(grid_size):
		var row = []
		for y in range(grid_size):
			row.append(Cell.new())
		maze.append(row)

	maze[0][0].visited = true
	stack.append(Vector2(0, 0))

	while stack.size() > 0:
		var current = stack[-1]
		var neighbors = get_unvisited_neighbors(current)

		if neighbors.size() > 0:
			var next = neighbors.pick_random()
			remove_wall(current, next)
			maze[next.x][next.y].visited = true
			stack.append(next)
		else:
			stack.pop_back()
	
	# Open connection to spawn box (top-left)
	maze[0][0].walls["top"] = false
	maze[0][0].walls["left"] = false

	## Open connection to exit box (bottom-right)
	#maze[grid_size - 1][grid_size - 1].walls["bottom"] = false
	#maze[grid_size - 1][grid_size - 1].walls["right"] = false


func get_unvisited_neighbors(pos: Vector2):
	var neighbors = []
	for dir in directions:
		var nx = pos.x + dir.x
		var ny = pos.y + dir.y
		if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size and !maze[nx][ny].visited:
			neighbors.append(Vector2(nx, ny))
	return neighbors

func remove_wall(current: Vector2, next: Vector2):
	var dx = next.x - current.x
	var dy = next.y - current.y

	if dx == 1:
		maze[current.x][current.y].walls["right"] = false
		maze[next.x][next.y].walls["left"] = false
	elif dx == -1:
		maze[current.x][current.y].walls["left"] = false
		maze[next.x][next.y].walls["right"] = false
	elif dy == 1:
		maze[current.x][current.y].walls["bottom"] = false
		maze[next.x][next.y].walls["top"] = false
	elif dy == -1:
		maze[current.x][current.y].walls["top"] = false
		maze[next.x][next.y].walls["bottom"] = false

# convert maze data into static collision walls with random colored visuals
func convert_maze_to_walls():
	# clear old walls if any 
	for child in maze_walls_container.get_children():
		child.queue_free()

	for x in range(grid_size):
		for y in range(grid_size):
			var cell = maze[x][y]
			var px = x * cell_size
			var py = y * cell_size

			if cell.walls["top"]:
				spawn_wall(Vector2(px, py), Vector2(cell_size, wall_thickness))
			if cell.walls["right"]:
				spawn_wall(Vector2(px + cell_size - wall_thickness, py), Vector2(wall_thickness, cell_size))
			if cell.walls["bottom"]:
				spawn_wall(Vector2(px, py + cell_size - wall_thickness), Vector2(cell_size, wall_thickness))
			if cell.walls["left"]:
				spawn_wall(Vector2(px, py), Vector2(wall_thickness, cell_size))

func spawn_wall(position: Vector2, size: Vector2):
	var adjusted_position = position - Vector2(overlap_size, overlap_size)
	var adjusted_size = size + Vector2(overlap_size * 2, overlap_size * 2)

	var wall = StaticBody2D.new()
	wall.position = adjusted_position
	wall.set_collision_layer_value(1, true)
	wall.set_collision_layer_value(2, true)
	wall.set_collision_layer_value(3, true)
	wall.set_collision_layer_value(4, true)
	wall.set_collision_mask_value(1, true)
	wall.set_collision_mask_value(2, true)
	wall.set_collision_mask_value(3, true)
	wall.set_collision_mask_value(4, true)
	
	var collider = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = adjusted_size
	collider.shape = shape
	collider.position = adjusted_size / 2.0
	wall.add_child(collider)

	# add colored visual wall
	var color_rect = ColorRect.new()
	#color_rect.color = Color.from_hsv(0.6, 0.6, 0.6)
	color_rect.color = Color.BLACK
	color_rect.size = adjusted_size
	color_rect.position = Vector2.ZERO
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wall.add_child(color_rect)

	maze_walls_container.add_child(wall)


func _on_head_to_ui_timeout() -> void:
	print("RESTARTING GAME...")
	get_tree().change_scene_to_file("res://scenes/main_ui.tscn")
	
