extends CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var target_to_chase: CharacterBody2D
@onready var detection_area: Area2D = $Area2D

const SPEED = 50.0

func _ready() -> void:
	set_physics_process(false)
	call_deferred("wait_for_physics")

func wait_for_physics():
	await get_tree().physics_frame
	set_physics_process(true)

func _on_body_entered(body: Node) -> void:
	print("A body has entered the area:", body.name)  # Debug print
	if body == target_to_chase:
		print("Enemy collided with the player!")

func _physics_process(delta: float) -> void:
	navigation_agent.target_position = target_to_chase.global_position
	var direction = global_position.direction_to(target_to_chase.global_position)
	velocity = direction * SPEED

	move_and_slide()
