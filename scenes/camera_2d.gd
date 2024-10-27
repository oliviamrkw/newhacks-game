extends Camera2D

var camera_speed: float = 30.0
var max_camera_speed: float = 200.0
var original_offset: Vector2

func _ready() -> void:
	original_offset = self.offset

func _process(delta: float) -> void:
	camera_speed = min(max_camera_speed, camera_speed + 0.05)
	self.offset.x += camera_speed * delta
	
func get_distance_travelled() -> float:
	return self.offset.x - original_offset.x

func reset_position() -> void:
	self.position = Vector2(150, global_position.y)
