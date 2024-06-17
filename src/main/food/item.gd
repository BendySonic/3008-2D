extends TextureRect

var item_resource: ItemResource
var is_selected := false
@onready var panel = get_node("PanelContainer")

func set_icon(icon: Texture2D):
	texture = icon

func _on_use_pressed():
	Global.player.add_food(item_resource.food)
	Global.player.remove_item()
	queue_free()


func _on_throw_pressed():
	var object_scene = load(item_resource.scene)
	var object = object_scene.instantiate()
	object.global_position = Global.player.global_position
	Global.main.map.add_child(object)
	Global.player.remove_item()
	queue_free()


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			panel.visible = not panel.visible


func _on_panel_container_mouse_entered():
	print("OO")
	Global.player.lock_move()

func _on_panel_container_mouse_exited():
	Global.player.unlock_move()
