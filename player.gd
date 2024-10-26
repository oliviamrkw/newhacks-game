extends CharacterBody2D

var sprite: AnimatedSprite2D
var speed: float = 100
var input_horizontal: float = 0.0
var gravity: float = 1000.0
var is_falling: bool = false
var jump_velocity: float = -350.0
var is_jumping: bool = false
var coyote_timer: Timer
var jump_timer: Timer

func _ready() -> void:
	sprite = $AnimatedSprite2D
	coyote_timer = $CoyoteTimer
	jump_timer = $JumpTimer

func handle_horizontal_movement(body: CharacterBody2D, direction: float) -> void:
	body.velocity.x = direction * speed

func _process(_delta: float) -> void:
	input_horizontal = Input.get_axis("move_left", "move_right")


func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")


func handle_gravity(body: CharacterBody2D, delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
		

	is_falling = body.velocity.y > 0 and not body.is_on_floor()

func automatic_jump(body: CharacterBody2D, timer: Timer) -> void:
	if body.is_on_floor():
		if timer.wait_time - timer.time_left == 0:
			body.velocity.y = jump_velocity
	
#func handle_jump(body: CharacterBody2D, want_to_jump: bool) -> void:
	#if body.is_on_floor():
		#has_jumped = false
		#coyote_timer.stop()
	#elif !body.is_on_floor():
		#coyote_timer.start()
		#
	#if want_to_jump and body.is_on_floor() or (not body.is_on_floor() and !has_jumped):
		#body.velocity.y = jump_velocity
		#has_jumped = true
#
	#is_jumping = body.velocity.y < 0


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
	
func _physics_process(delta: float) -> void:
	handle_gravity(self, delta)
	handle_horizontal_movement(self, input_horizontal)
	automatic_jump(self, jump_timer)
	#handle_jump(self, get_jump_input())
	handle_move_animation(input_horizontal)
	handle_jump_animation(is_jumping, is_falling)

	move_and_slide()
