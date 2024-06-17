extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_pressed():
	Global.main.can_pause = false
	get_tree().paused = false
	Global.main.animation.play("end")
	await Global.main.animation.animation_finished
	RenderingServer.set_default_clear_color(Color.WHITE)
	get_tree().change_scene_to_file("res://src/gameover/gameover.tscn")


func _on_continue_pressed():
	get_tree().paused = false
	Global.main.is_paused = false
	Global.main.pause.hide()
	Global.main.can_pause = true
