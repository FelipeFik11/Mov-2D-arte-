extends CharacterBody2D
@export var speed = 300
@export var acceleration = 800
@export var friction = 600
@export var jump_force = -500
@export var gravity = 1000
@export var max_fall_speed = 900 
@export var dash_speed = 600
@export var dash_time = 0.2
@export var dash_cooldown = 2
var was_in_air
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 2
var dash_direction = 0 
var max_dash = 1
var double_jump_used = false
var jump_count = 0
var max_jumps = 2
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("Fall")
	else:
		if velocity.x == 0:
			$AnimatedSprite2D.play("Idle")
		else:
			$AnimatedSprite2D.play("walk")	
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
	if is_dashing:
		$AnimatedSprite2D.play("dash")	
		
		$DashParticles2D.restart()		
	
	if dash_cooldown_timer > 0: 
		dash_cooldown_timer -= delta
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		is_dashing = true 
		dash_timer = dash_time
		dash_cooldown_timer = dash_cooldown
		dash_direction = sign(velocity.x)
		if dash_direction == 0:
			dash_direction = 1 

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * dash_speed
		velocity.y = 0 
		if dash_timer <= 0:
			is_dashing = false
		move_and_slide()	
		return	
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		jump_count = 0
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = - 400
		$JumpParticles.restart()
	$WalkParticles.emitting = abs(velocity.x) > 10 and is_on_floor()
	if velocity.x != 0:
		$WalkParticles.scale.x = -sign(velocity.x)	
		
	var direction = Input.get_axis("izquierda", "derecha")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x,0, friction * delta)
	if Input.is_action_just_pressed("saltar") and jump_count < max_jumps:
		velocity.y = jump_force
		jump_count += 1			
	
	move_and_slide()
