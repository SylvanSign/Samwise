extends Camera2D

export(int) var speed := 500

func _process(delta: float) -> void:
	var input := Input.get_vector('left', 'right', 'up', 'down')
	position += input * speed * delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_left'):
		zoom /= 2
	elif event.is_action_pressed('ui_right'):
		zoom *= 2
