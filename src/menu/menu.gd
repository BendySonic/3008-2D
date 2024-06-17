extends Control

var start_position = Vector2(-1200, -600)

var achievement_scene = preload("res://src/menu/achivement.tscn")

@onready var background = get_node("Background")
@onready var animation = get_node("AnimationPlayer")
@onready var play = get_node("Play")
@onready var main = get_node("Main")
@onready var settings = get_node("Settings")
@onready var achievements = get_node("Achievements")
@onready var achievements_grid = get_node("Achievements/VBoxContainer/GridContainer")

func _ready():
	Music.get_node("Menu").play()
	RenderingServer.set_default_clear_color(Color(0.082, 0.082, 0.082))
	animation.play("launch")
	
	for achievement in Global.achievements:
		var new_achievement = achievement_scene.instantiate()
		var data = Global.achievements[achievement]
		new_achievement.set_data(achievement, data[1], data[0])
		achievements_grid.add_child(new_achievement)

func _process(delta):
	background.global_position += Vector2(609, 357).normalized() * 100 * delta
	var local_position = background.global_position - start_position
	if local_position.x >= 609:
		background.global_position -= Vector2(609, 357)


func _on_start_pressed():
	animation.play("start")
	await animation.animation_finished
	Music.get_node("Menu").stop()
	get_tree().change_scene_to_file("res://src/main/main.tscn")


func _on_play_pressed():
	smooth_trans(main, play)

func smooth_trans(a, b):
	var alpha = 1
	while not a.modulate == Color(1, 1, 1, 0):
		a.modulate = Color(1, 1, 1, alpha)
		alpha -= 0.05
		alpha = clamp(alpha, 0, 1)
		await get_tree().physics_frame
	alpha = 0
	a.visible = false
	b.visible = true
	b.modulate = Color(1, 1, 1, 0)
	while not b.modulate == Color(1, 1, 1, 1):
		b.modulate = Color(1, 1, 1, alpha)
		alpha += 0.05
		alpha = clamp(alpha, 0, 1)
		await get_tree().physics_frame


func _on_play_back_pressed():
	smooth_trans(play, main)


func _on_check_box_toggled(toggled_on):
	Global.is_new = toggled_on


func _on_settings_back_pressed():
	smooth_trans(settings, main)


func _on_settings_pressed():
	smooth_trans(main, settings)


func _on_dynamic_camera_check_box_toggled(toggled_on):
	Global.is_dynamic_camera = toggled_on


func _on_full_screen_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_achievements_pressed():
	smooth_trans(main, achievements)


func _on_achievements_back_pressed():
	smooth_trans(achievements, main)
