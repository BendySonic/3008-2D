class_name Enemy
extends CharacterBody2D


var speed = 100
var accel = 7

var is_chase := false
var random_target: Vector2 = global_position

@onready var nav = get_node("NavigationAgent2D")

func _physics_process(delta):
	var length = Global.player.global_position - global_position
	if length.length() < 300 and not is_chase and not Global.main.is_day:
		is_chase = true
		await get_tree().create_timer(0.5).timeout 
		$Voice.play()
	elif length.length() > 500 and is_chase or Global.main.is_day:
		is_chase = false
		$Voice.stop()
	
	if is_chase:
		# Add the gravitywas
		var direction = Vector2()
		
		nav.target_position = Global.player.global_position

		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * speed, accel * delta)
		move_and_slide()
	else:
		if (random_target - global_position).length() < 100:
			random_target = global_position + Vector2(randi_range(-600, 600), randi_range(-600, 600))
		elif (Global.player.global_position - global_position).length() < 400:
			var direction = Vector2()
			
			nav.target_position = random_target
			
			direction = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction * speed * 0.25, accel * delta)
			move_and_slide()
		else:
			var direction = random_target - global_position
			velocity = direction.normalized() * speed * 0.25
			move_and_slide()
			


func _on_voice_finished():
	if is_chase:
		$Voice.play()
