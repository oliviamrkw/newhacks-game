extends Area2D

func _on_body_entered(body: Node) -> void:
	print("A body has entered the area:", body.name, "Type:", body.get_class())
