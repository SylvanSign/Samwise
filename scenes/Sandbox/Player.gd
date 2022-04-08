extends Camera2D

export(int) var speed := 1000
export(float) var zoom_factor := 1.5

func _process(delta: float) -> void:
	var input := Input.get_vector('left', 'right', 'up', 'down')
	position += input * speed * zoom * delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_left'):
		zoom /= zoom_factor
	elif event.is_action_pressed('ui_right'):
		zoom *= zoom_factor
