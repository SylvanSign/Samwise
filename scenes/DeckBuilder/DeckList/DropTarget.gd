extends Control

signal dropped(data)

func can_drop_data(_position: Vector2, _dd: Dictionary) -> bool:
	return true


func drop_data(_position: Vector2, dd: Dictionary) -> void:
	emit_signal("dropped", dd)
