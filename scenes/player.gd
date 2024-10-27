extends CharacterBody2D

var sprite: AnimatedSprite2D
var speed: float = 100.0
var max_speed: float = 300
var current_speed: float = 0.0
var acceleration: float = 10.0
var speed_increase_step: float = 5
var input_horizontal: float = 0.0
var gravity: float = 1000.0
var is_falling: bool = false
var jump_velocity: float = -300.0
var min_jump_velocity: float = -100.0
var is_jumping: bool = false
var coyote_timer: Timer
var jump_timer: Timer
var respawn_point: Vector2
var fall_threshold: float = 300.0
var background: ColorRect
var heartbeat: AudioStreamPlayer2D
var dash: AudioStreamPlayer2D
var is_dashing: bool = false
var dash_speed: float = 500 
var dash_duration: float = 0.2
var dash_timer: float = 0.0

var initial_wait_time: float = 1.0
var min_wait_time: float = 0.2 
var time_decrease_step: float = 0.005
var jump_decrease: float = 1
var color_intensity: float = 0

var camera: Camera2D

func _ready() -> void:
	sprite = $AnimatedSprite2D
	coyote_timer = $CoyoteTimer
	jump_timer = $JumpTimer
	background = $Background
	heartbeat = $Heartbeat
	dash = $Dash
	jump_timer.start()
	jump_timer.timeout.connect(_on_timer_timeout)
	respawn_point = global_position
	camera = get_node("/root/Game/World/Camera2D")

func _on_timer_timeout() -> void:
	automatic_jump(self)
	
	if jump_timer.wait_time > min_wait_time:
		jump_timer.wait_time = max(jump_timer.wait_time - time_decrease_step, min_wait_time)

	jump_timer.start(jump_timer.wait_time)
	
	if jump_velocity < min_jump_velocity:
		jump_velocity = min(min_jump_velocity, jump_velocity+jump_decrease)
	
	if speed < max_speed:
		speed = min(speed + speed_increase_step, max_speed)
		
	flash_background()
	color_intensity += 0.01
	
func handle_player_boundaries() -> void:
	var camera_left_edge = camera.get_distance_travelled() - 300
	var camera_right_edge = camera.get_distance_travelled() + 300
	var position = global_position.x - 156
	
	if position > camera_right_edge:
		velocity.x = 0 
		global_position.x = camera_right_edge

	# Respawn if the player goes behind the left side of the camera
	if position < camera_left_edge:
		print("left edge")
		total_respawn()
	
func handle_horizontal_movement(body: CharacterBody2D, direction: float) -> void:
	if !is_dashing:
		if direction != 0:  # If there's input, accelerate
			current_speed = min(current_speed + acceleration * get_process_delta_time(), max_speed)
		else: 
			current_speed = max(current_speed - acceleration * get_process_delta_time(), 0)
		body.velocity.x = direction * speed

func _process(_delta: float) -> void:
	input_horizontal = Input.get_axis("move_left", "move_right")
	get_dash_input()

func get_dash_input() -> void:
	if Input.is_action_just_pressed("dash") and !is_dashing:
		start_dash()

func start_dash() -> void:
	is_dashing = true
	dash.play()
	dash_timer = dash_duration
	velocity.x = dash_speed if input_horizontal >= 0 else -dash_speed

func handle_dash(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			stop_dash()

func stop_dash() -> void:
	is_dashing = false
	velocity.x = 0 

func handle_gravity(body: CharacterBody2D, delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	else:
		update_respawn_point()

	is_falling = body.velocity.y > 0 and not body.is_on_floor()

func update_respawn_point() -> void:
	respawn_point = global_position
	
func check_for_fall() -> void:
	if global_position.y > fall_threshold:
		respawn()
		
func respawn() -> void:
	global_position = respawn_point 
	velocity = Vector2.ZERO
	
func total_respawn() -> void:
	global_position = Vector2(100, 156)
	velocity = Vector2.ZERO
	camera.reset_position()

func automatic_jump(body: CharacterBody2D) -> void:
	if body.is_on_floor():
		body.velocity.y = jump_velocity
		heartbeat.play()

func handle_horizontal_flip(move_direction: float) -> void:
	if move_direction == 0:
		return

	sprite.flip_h = false if move_direction > 0 else true


func handle_move_animation(move_direction: float) -> void:
	handle_horizontal_flip(move_direction)
	sprite.play("walk")

func handle_jump_animation(jumping: bool, falling: bool) -> void:
	if jumping:
		sprite.play("jump")
	elif falling:
		sprite.play("fall")
	
func flash_background() -> void:
	var original_color = background.color  # Save the original color
	background.color = Color(1, 0, 0, 1)  # Set to red
	
	var tween = create_tween()
	tween.tween_property(background, "color", original_color, 0.3)	

func _physics_process(delta: float) -> void:
	handle_gravity(self, delta)
	handle_horizontal_movement(self, input_horizontal)
	handle_move_animation(input_horizontal)
	handle_jump_animation(is_jumping, is_falling)
	check_for_fall()
	handle_dash(delta)
	handle_player_boundaries()
		
	background.color = Color(1, 0.9-color_intensity, 0.9-color_intensity, 1)
	move_and_slide()
