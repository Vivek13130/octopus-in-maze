extends Node2D

@export var cell_size: int = 120
@export var wall_thickness: float = 1.0
@export var overlap_size: float = 20.0
@export var loops_in_maze : float = 0.4
# increase this value for more correct paths in maze

var grid_size = 5
@export var player_scene : PackedScene
@export var enemy_scene : PackedScene
@export var counting_tile_scene : PackedScene

@onready var player_container := $playerContainer 
@onready var maze_walls_container: Node2D = $mazeWallsContainer
@onready var head_to_ui: Timer = $headToUI
@onready var spawn_exit_box_container: Node2D = $spawn_exit_box_container

@onready var in_game_equation: Control = $"CanvasLayer/in-game-equation"


class Cell:
	var visited = false
	var walls = { "top": true, "right": true, "bottom": true, "left": true }

var maze = []
var stack = []
var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
var player 
var player_body 

func _ready():
	# load the variables from manager : 
	loops_in_maze = (1 - Manager.maze_complexity)
	Manager.cell_size = cell_size
	grid_size = Manager.grid_size
	print("loops : ", loops_in_maze)
	
	generate_maze()
	
	spawn_exit_box()
	convert_maze_to_walls()
	
	spawn_player()
	
	spawn_counting_tiles()
	#spawn_enemies(grid_size)
	#spawn_orbs(0 , grid_size / 2)

func _process(delta: float) -> void:
	if(Manager.reached_exit) : 
		Manager.time_to_ui = head_to_ui.time_left
	
	check_exit_status()
	
	if(Manager.show_path_traveled):
		$Line2D.points = Manager.path_of_player

func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func check_exit_status():
	
	if Manager.equation_solved == Manager.equation_count and !Manager.reached_exit:
		Manager.reached_exit = true
		$Line2D.points = Manager.path_of_player
		$residueContainer.visible = false
		head_to_ui.start()
		print("Player reached out of grid! Timer started")
		
		for enemy in Manager.enemy_list:
			if is_instance_valid(enemy):
				enemy.explode()




func spawn_player():
	print("player spawned")
	player = player_scene.instantiate()
	player_body = player.get_child(2)
	var spawn_box_center = Vector2(cell_size/2, -cell_size )  # since spawn box will be placed at top-left
	player.global_position = spawn_box_center
	player_container.add_child(player)


func spawn_enemies(count: int):
	for i in range(count):
		var enemy = enemy_scene.instantiate()
		enemy.add_to_group("enemy")

		# start spawn from 25% of grid_size to 100%
		var min_coord = grid_size * 0.25 * cell_size
		var safe_x = randf_range(min_coord, (grid_size - 1.5) * cell_size)
		var safe_y = randf_range(min_coord, (grid_size - 1.5) * cell_size)

		enemy.global_position = Vector2(safe_x, safe_y)
		add_child(enemy)
		Manager.enemy_list.append(enemy)


func spawn_counting_tiles():
	var available_cells = []
	var values_set = Manager.counting_values_set
	
	# Generate all valid grid cells (excluding walls)
	for x in range(0, grid_size):
		for y in range(0, grid_size):
			available_cells.append(Vector2(x, y))

	available_cells.shuffle()  # Randomize placement

	# Limit to unique positions for counting tiles
	var selected_cells = available_cells.slice(0, values_set.size())

	for i in range(values_set.size()):
		var cell = selected_cells[i]
		var tile = counting_tile_scene.instantiate()
		tile.get_node("PanelContainer").get_child(0).text = str(values_set[i])  # Assign value to label

		# Convert grid position to world position (center of the cell)
		tile.global_position = (cell + Vector2(0.5, 0.5)) * cell_size
		add_child(tile)

	print("\nPlaced Counting Tiles at:", selected_cells)


func create_wall(position: Vector2, size: Vector2, color: Color) -> StaticBody2D:
	var wall = StaticBody2D.new()
	wall.position = position
	wall.add_to_group("wall")
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
	shape.size = size
	collider.shape = shape
	collider.position = size / 2.0
	wall.add_child(collider)

	var sprite = Sprite2D.new()
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.position = size / 2
	wall.add_child(sprite)

	return wall


func spawn_spawn_box():
	var base_pos = Vector2(-cell_size - overlap_size, -cell_size - overlap_size)

	# Top wall (2 parts with small opening)
	var top_wall = create_wall(base_pos, Vector2(cell_size * 2, wall_thickness + overlap_size), Color.YELLOW)
	#var top_wall_left = create_wall(base_pos, Vector2(cell_size , wall_thickness + overlap_size), Color.YELLOW)
	#var top_wall_right = create_wall(base_pos + Vector2(cell_size , 0), Vector2(cell_size, wall_thickness + overlap_size), Color.YELLOW)

	# Left wall (2 parts with opening)
	var left_wall = create_wall(base_pos, Vector2(wall_thickness + overlap_size, cell_size * 2), Color.YELLOW)
	
	#var left_wall_top = create_wall(base_pos, Vector2(wall_thickness + overlap_size, cell_size), Color.YELLOW)
	#var left_wall_bottom = create_wall(base_pos + Vector2(0, cell_size ), Vector2(wall_thickness + overlap_size, cell_size ), Color.YELLOW)

	# Bottom wall
	var bottom_wall = create_wall(base_pos + Vector2(0, 2 * cell_size), Vector2(cell_size , wall_thickness + overlap_size), Color.YELLOW)

	# Right wall
	var right_wall = create_wall(base_pos + Vector2(2 * cell_size, 0), Vector2(wall_thickness+ overlap_size, cell_size ), Color.YELLOW)

	spawn_exit_box_container.add_child(top_wall)
	spawn_exit_box_container.add_child(left_wall)
	#spawn_exit_box_container.add_child(top_wall_left)
	#spawn_exit_box_container.add_child(top_wall_right)
	#spawn_exit_box_container.add_child(left_wall_top)
	#spawn_exit_box_container.add_child(left_wall_bottom)
	spawn_exit_box_container.add_child(bottom_wall)
	spawn_exit_box_container.add_child(right_wall)



func spawn_exit_box():
	var base_pos = Vector2((grid_size - 1) * cell_size + overlap_size , (grid_size - 1) * cell_size + overlap_size)

	# Top wall (2 parts with small opening)
	#var top_wall_left = create_wall(base_pos, Vector2(cell_size, wall_thickness + overlap_size), Color.GREEN)
	var top_wall_right = create_wall(base_pos + Vector2(cell_size , 0) , Vector2(cell_size , wall_thickness + overlap_size), Color.GREEN)

	# Left wall (2 parts with opening)
	#var left_wall_top = create_wall(base_pos, Vector2(wall_thickness + overlap_size, cell_size), Color.GREEN)
	var left_wall_bottom = create_wall(base_pos + Vector2(0, cell_size), Vector2(wall_thickness + overlap_size, cell_size), Color.GREEN)

	# Bottom wall
	var bottom_wall = create_wall(base_pos + Vector2(0, 2 * cell_size), Vector2(2 * cell_size + overlap_size, wall_thickness + overlap_size), Color.GREEN)

	# Right wall
	var right_wall = create_wall(base_pos + Vector2(2 * cell_size, 0), Vector2(wall_thickness + overlap_size, 2 * cell_size + overlap_size), Color.GREEN)

	#spawn_exit_box_container.add_child(top_wall_left)
	spawn_exit_box_container.add_child(top_wall_right)
	#spawn_exit_box_container.add_child(left_wall_top)
	spawn_exit_box_container.add_child(left_wall_bottom)
	spawn_exit_box_container.add_child(bottom_wall)
	spawn_exit_box_container.add_child(right_wall)



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
	
	# open connection to spawn box (top-left)
	maze[0][0].walls["top"] = false
	maze[0][0].walls["left"] = false

	## open connection to exit box (bottom-right)
	maze[grid_size - 1][grid_size - 1].walls["bottom"] = false
	maze[grid_size - 1][grid_size - 1].walls["right"] = false
	
	add_loops(loops_in_maze)  



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

# adding loops to wall for it to have multiple correct paths 
func add_loops(loop_chance: float = 0.1):
	for x in range(grid_size):
		for y in range(grid_size):
			for dir in directions:
				var nx = x + dir.x
				var ny = y + dir.y
				if nx >= 0 and ny >= 0 and nx < grid_size and ny < grid_size:
					if maze[x][y].walls[get_wall_key(dir)] and randf() < loop_chance:
						# Remove wall to create loop
						maze[x][y].walls[get_wall_key(dir)] = false
						maze[nx][ny].walls[get_opposite_wall_key(dir)] = false


# helper function for adding loops : 
func get_wall_key(dir: Vector2) -> String:
	if dir == Vector2(1, 0):
		return "right"
	elif dir == Vector2(-1, 0):
		return "left"
	elif dir == Vector2(0, 1):
		return "bottom"
	elif dir == Vector2(0, -1):
		return "top"
	return ""

func get_opposite_wall_key(dir: Vector2) -> String:
	return get_wall_key(-dir)


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

	wall.add_to_group("wall")
	
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
	
