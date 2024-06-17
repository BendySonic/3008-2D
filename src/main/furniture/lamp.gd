extends BaseFurniture


func _physics_process(delta):
	if (global_position - Global.player.global_position).length() > 500:
		$PointLight2D.enabled = false
	else:
		$PointLight2D.enabled = true
	super(delta)
