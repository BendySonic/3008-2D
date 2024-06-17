extends Camera2D

@onready var player = get_parent().get_node("Player")


func _physics_process(delta):
	if Global.is_dynamic_camera:
		drag_left_margin = 0.15
		drag_right_margin = 0.15
		drag_top_margin = 0.15
		drag_bottom_margin = 0.15
		position_smoothing_speed = 2.5
	else:
		drag_left_margin = 0.0
		drag_right_margin = 0.0
		drag_top_margin = 0.0
		drag_bottom_margin = 0.0
		position_smoothing_speed = 5
	if not player == null and not Global.main.is_paused:
		if Global.is_dynamic_camera:
			global_position = get_global_mouse_position()
			var player_relative_position = global_position - player.global_position
			player_relative_position.x = clamp(player_relative_position.x, -100, 100)
			player_relative_position.y = clamp(player_relative_position.y, -100, 100)
			global_position = player.global_position + player_relative_position
		else:
			global_position = player.global_position
