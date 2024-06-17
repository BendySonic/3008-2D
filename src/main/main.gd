extends Node2D

signal tooltip_showed

const AREA_OFFSET = Vector2(300, 300)

# Я ЗНАЮ ЧТО ВЕСЬ ПРОЕКТ - ПОЛНЫЙ ГОВНОКОД, НО У МЕНЯ ОСТАЛОСЬ МАЛО ВРЕМЕНИ ДО КОНЦА ДЖЕМА!
var item_scene = preload("res://src/main/food/item.tscn")
@onready var item_slots: Array = [
	get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer/VBoxContainer2/MarginContainer/" +
			"VBoxContainer/MarginContainer/AspectRatioContainer/Panel"),
	get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer/VBoxContainer2/MarginContainer/" +
			"VBoxContainer/MarginContainer2/AspectRatioContainer/Panel"),
	get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer/VBoxContainer2/MarginContainer/" +
			"VBoxContainer/MarginContainer3/AspectRatioContainer/Panel"),
	get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer/VBoxContainer2/MarginContainer/" +
			"VBoxContainer/MarginContainer4/AspectRatioContainer/Panel")
]

var enemy_scene = preload("res://src/main/enemy/enemy.tscn")

var loaded_areas: Array[Vector2]
var area_scenes: Array[PackedScene]

var is_day := true
var day: int = 1
var night: int = 1

var can_pause := false
var is_paused := false

@onready var animation = get_node("AnimationPlayer")

@onready var map = get_node("Map")
@onready var player = get_node("Player")
@onready var shadow = get_node("Shadow")
@onready var enemies = get_node("Enemies")

@onready var tooltip = get_node("CanvasLayer/Effects/HBoxContainer/" + 
		"PanelContainer2/Tooltip")
@onready var time = get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer2/VBoxContainer/Time")
@onready var food = get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer" +
		"/VBoxContainer2/MarginContainer2/HBoxContainer/Food")
@onready var hp = get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer/" +
		"VBoxContainer2/MarginContainer2/HBoxContainer/Hp")
@onready var tip = get_node("CanvasLayer/Effects/HBoxContainer/PanelContainer2/VBoxContainer/MarginContainer/Tip")

@onready var pause = get_node("CanvasLayer/Effects/Pause")
@onready var achievement = get_node("CanvasLayer/Achievement")

func _init():
	for i in range(1, 11):
		var area_scene = load("res://src/main/areas/area_" + str(i) + ".tscn")
		area_scenes.push_back(area_scene)

func _ready():
	RenderingServer.set_default_clear_color(Color.WHITE)
	Global.main = self
	Global.player = player
	food.set_value(player.food)
	food.set_value(player.hp)
	player.food_changed.connect(on_food_changed)
	player.hp_changed.connect(on_hp_changed)
	player.item_added.connect(on_item_added)
	map.bake_navigation_polygon(true)
	animation.play("start")
	
	await animation.animation_finished
	Music.get_node("Monday").play()
	
	can_pause = true
	
	if Global.is_new:
		tip.show()
		tip.text = "Для перемещения используй мышку (Зажми)"
		await Global.player.moved
		await get_tree().create_timer(2).timeout
		tip.text = "Динамическая камера следует за мышкой\nЭто можно изменить в настройках (клавиша ESC)"
		await get_tree().create_timer(10).timeout
		tip.text = "Наведи мышку на мебель или предмет для подсказок"
		await tooltip_showed
		await get_tree().create_timer(5).timeout
		tip.text = "Пополнять запасы еды можно на кухне\nи кое-где ещё. Остерегайся ночи!"
		await get_tree().create_timer(10).timeout
		tip.hide()

func _physics_process(delta):
	shadow.global_position = player.global_position
	for i in range(-1, 2):
		for j in range(-1, 2):
			var player_area_position = get_player_area_position()
			create_area(player_area_position.x + i, player_area_position.y + j)
	for enemy in enemies.get_children():
		var enemy_player_local_position = player.global_position - enemy.global_position
		if enemy_player_local_position.length() > 1700:
			enemy.queue_free()
	if enemies.get_child_count() < 4:
		var enemy = enemy_scene.instantiate()
		enemy.global_position = Vector2(randi_range(-1600, 1600), randi_range(-1600, 1600))
		enemies.scale = Vector2(4, 4)
		enemies.add_child(enemy)

func _input(event):
	if Input.is_action_just_pressed("pause") and can_pause:
		is_paused = not is_paused
		can_pause = false
		if is_paused:
			pause.show()
			get_tree().paused = true

func create_area(x, y):
	if not loaded_areas.has(Vector2(x, y)):
		var area
		var random = randi_range(1, 100)
		if random >= 89 and random <= 99:
			area = area_scenes[7].instantiate()
		elif random == 100:
			area = area_scenes[6].instantiate()
		elif random >= 80 and random < 89:
			area = area_scenes[8].instantiate()
		elif random > 74 and random < 80:
			area = area_scenes[9].instantiate()
		else:
			area = area_scenes[randi_range(0, 5)].instantiate()
		area.position = Vector2(x * 600, y * 600) + AREA_OFFSET
		loaded_areas.push_back(Vector2(x, y))
		map.add_child(area)

func get_player_area_position():
	return floor(player.position / 600)

func show_tooltip(text: String):
	tooltip.set_text(text)
	tooltip.show()
	tooltip_showed.emit()

func hide_tooltip():
	tooltip.hide()

func on_food_changed(value):
	food.set_value(value)

func on_hp_changed(value):
	hp.set_value(value)

func on_item_added(item_resource):
	for item_slot in item_slots:
		if item_slot.get_children().size() == 0:
			var item = item_scene.instantiate()
			item.item_resource = item_resource
			item.set_icon(item_resource.icon)
			item_slot.add_child(item)
			break


func _on_day_timer_timeout():
	is_day = not is_day
	if is_day:
		day += 1
		set_day()
		time.set_text(str(day) + " День")
	else:
		night += 1
		set_night()
		time.set_text(str(day) + " Ночь")

func set_day():
	Music.get_node("TurnOn").play()
	if (day + 4) % 5 == 0:
		Music.get_node("Monday").play()
	elif (day - 2) % 5 == 0:
		Music.get_node("Tuesday").play()
	elif (day - 3) % 5 == 0:
		Music.get_node("Wednesday").play()
	elif (day - 4) % 5 == 0:
		Music.get_node("Thursday").play()
	elif day % 5 == 0:
		Music.get_node("Friday").play()
	
	if day == 2:
		Global.achievements["Ночь 1"][0] = true
		achievement.set_data("Ночь 1", Global.achievements["Ночь 1"][1], true)
	elif day == 3:
		Global.achievements["Ночь 2"][0] = true
		achievement.set_data("Ночь 2", Global.achievements["Ночь 2"][1], true)
	elif day == 4:
		Global.achievements["Ночь 3"][0] = true
		achievement.set_data("Ночь 3", Global.achievements["Ночь 3"][1], true)
	elif day == 5:
		Global.achievements["Ночь 4"][0] = true
		achievement.set_data("Ночь 4", Global.achievements["Ночь 4"][1], true)
	elif day == 6:
		Global.achievements["Ночь 5"][0] = true
		achievement.set_data("Ночь 5", Global.achievements["Ночь 5"][1], true)
	animation.play("show_achievement")
	Global.save_data()
	
	RenderingServer.set_default_clear_color(Color.WHITE)
	time.label_settings.font_color = Color.BLACK
	player.set_day()

func set_night():
	Music.stop_all_sounds()
	Music.get_node("TurnOff").play()
	RenderingServer.set_default_clear_color(Color.BLACK)
	time.label_settings.font_color = Color.WHITE
	player.set_night()


func _on_map_bake_finished():
	var navigation_polygon_outline: PackedVector2Array = [
		player.global_position + Vector2(-400, -400),
		player.global_position + Vector2(400, -400),
		player.global_position + Vector2(400, 400),
		player.global_position + Vector2(-400, 400),
	]
	map.navigation_polygon.set_outline(0, navigation_polygon_outline)
	map.bake_navigation_polygon(true)


func _on_dynamic_camera_check_box_toggled(toggled_on):
	Global.is_dynamic_camera = toggled_on


func _on_full_screen_check_box_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
