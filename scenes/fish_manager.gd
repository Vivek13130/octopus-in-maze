extends Node2D

var fish_speed = 50
var turn_chance = 0.5
var max_turn_angle = deg_to_rad(2)  # Limit how much they can turn per frame

func _process(delta):
	var screen_rect = get_viewport_rect()

	for fish in get_children():
		if not fish.has_meta("dir"):
			var init_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			fish.set_meta("dir", init_dir)

		var dir = fish.get_meta("dir")

		# Random steering
		if randf() < turn_chance:
			var random_target = dir.rotated(deg_to_rad(randf_range(-45, 45))).normalized()
			dir = steer_towards(dir, random_target, max_turn_angle)

		var next_pos = fish.position + dir * fish_speed * delta

		# Bounce back if leaving screen
		if not screen_rect.has_point(next_pos):
			var to_center = (screen_rect.size / 2 - fish.position).normalized()
			dir = steer_towards(dir, to_center, max_turn_angle)

		# Move and rotate
		fish.set_meta("dir", dir)
		fish.position += dir * fish_speed * delta
		fish.rotation = dir.angle()

func steer_towards(current: Vector2, target: Vector2, max_angle: float) -> Vector2:
	var angle_diff = current.angle_to(target)
	angle_diff = clamp(angle_diff, -max_angle, max_angle)
	return current.rotated(angle_diff).normalized()
