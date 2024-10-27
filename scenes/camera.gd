extends Camera2D

var camera: Camera2D
var camera_speed: float = 50.0

func _ready() -> void:
	var camera = $World/Camera

func _process(delta: float) -> void:
	camera.offset.x += camera_speed * delta
