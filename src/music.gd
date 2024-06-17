extends Node



func _on_walk_finished():
	$Walk.play()


func _on_monday_finished():
	$Monday.play()

func stop_all_sounds():
	for child in get_children():
		child.stop()
