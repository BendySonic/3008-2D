class_name BaseFurniture
extends CharacterBody2D


var is_mouse_inside := false
var is_hold := false

func _on_mouse_entered():
	is_mouse_inside = true
	if not (Global.is_hold and not is_hold) and not is_hold:
		Global.show_tooltip("Z - переместить\nX - использовать")

func _on_mouse_exited():
	is_mouse_inside = false
	if not (Global.is_hold and not is_hold) and not is_hold:
		Global.hide_tooltip()


func _input(event):
	if Input.is_action_just_pressed("move"):
		if is_hold:
			Global.is_hold = not Global.is_hold
			is_hold = not is_hold
			collision_layer = 4
			collision_mask = 5
			modulate = Color(1, 1, 1, 1)
			Global.hide_tooltip()
			Music.get_node("Set").play()
		elif not (Global.is_hold and not is_hold) and is_mouse_inside:
			Global.is_hold = not Global.is_hold
			is_hold = not is_hold
			if is_hold:
				collision_layer = 2
				collision_mask = 4
				modulate = Color(1, 1, 1, 0.3)
				Global.show_tooltip("C - повернуть\nZ - поставить")
	if Input.is_action_just_pressed("rotate") and is_hold:
		rotation += PI / 4

func _physics_process(delta):
	var local_mouse_position = get_global_mouse_position() - global_position
	if is_hold and local_mouse_position.length() > 15:
		velocity = (local_mouse_position).normalized() * 700
		move_and_slide()
