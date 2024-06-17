class_name BaseFood
extends CharacterBody2D

var is_mouse_inside

@export var item_resource: ItemResource

func _on_mouse_entered():
	is_mouse_inside = true
	Global.show_tooltip("F - забрать\nX - использовать")

func _on_mouse_exited():
	is_mouse_inside = false
	Global.hide_tooltip()

func _input(event):
	if Input.is_action_just_pressed("use") and is_mouse_inside:
		var player = Global.player
		player.add_food(10)
		queue_free()
	if Input.is_action_just_pressed("take") and is_mouse_inside:
		var player = Global.player
		if player.add_item(item_resource):
			Music.get_node("PickUp").play()
			queue_free()
