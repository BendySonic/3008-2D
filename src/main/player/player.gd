extends CharacterBody2D

signal hp_changed(value)
signal food_changed(value)
signal item_added(item_resource)
signal item_throwed(item_resource)
signal moved

@export var speed = 35

var is_move := false
var is_move_locked := false

var hp: float = 100
var food: float = 100
var is_invincible := false
var is_attacked := false

var items: Array[ItemResource]

@onready var night = get_node("Night")
@onready var hp_timer = get_node("HpTimer")


func _ready():
	food_changed.emit(food)
	hp_changed.emit(hp)

func _input(event):
	look_at(get_global_mouse_position())
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not is_move_locked:
			is_move = event.is_pressed()
			moved.emit()
			if is_move:
				Music.get_node("Walk").play()
			else:
				Music.get_node("Walk").stop()

func _physics_process(delta):
	if is_move:
		decrease_food(0.15 * delta)
	
	if is_move:
		velocity = transform.x * speed
	else:
		velocity = Vector2(0, 0)
	
	if is_close_to_mouse():
		velocity = Vector2(0, 0)
	
	if not is_move_locked:
		move_and_slide()
	
	if is_attacked and not is_invincible:
		decrease_hp(20)

func is_close_to_mouse():
	return (global_position - get_global_mouse_position()).length() < 20

func add_food(value: float):
	food += value
	food = clamp(food, 0.0, 100.0)
	food_changed.emit(food)

func decrease_food(value: float):
	food -= value
	food = clamp(food, 0.0, 100.0)
	food_changed.emit(food)
	
	if food <= 0:
		decrease_hp(20)

func decrease_hp(value: float):
	hp -= value
	is_invincible = true
	hp_timer.start()
	hp_changed.emit(hp)
	
	Global.main.animation.play("hurt")
	Music.get_node("Punch").play()
	
	if hp <= 0:
		var tree = get_tree()
		Global.main.can_pause = false
		Global.main.animation.play("end")
		await Global.main.animation.animation_finished
		RenderingServer.set_default_clear_color(Color.WHITE)
		tree.change_scene_to_file("res://src/gameover/gameover.tscn")

func set_night():
	night.show()

func set_day():
	night.hide()

func add_item(item: ItemResource):
	if items.size() < 4:
		items.push_back(item)
		item_added.emit(item)
		return true
	else:
		return false

func remove_item():
	for item in items:
		items.erase(item)

func lock_move():
	is_move_locked = true

func unlock_move():
	is_move_locked = false

func _on_area_2d_body_entered(body):
	if body is Enemy and not is_invincible and not Global.main.is_day:
		if not is_attacked:
			decrease_hp(20)
			is_attacked = true

func _on_hp_timer_timeout():
	is_invincible = false


func _on_area_2d_body_exited(body):
	if body is Enemy:
		is_attacked = false
