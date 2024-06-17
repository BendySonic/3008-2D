extends Control

@onready var animation = get_node("AnimationPlayer")

func _ready():
	RenderingServer.set_default_clear_color(Color.WHITE)
	Music.stop_all_sounds()
	Music.get_node("Doors").play()
	animation.play("gameover")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	animation.play("reborn")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://src/main/main.tscn")


func _on_button_2_pressed():
	animation.play("death")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://src/menu/menu.tscn")
