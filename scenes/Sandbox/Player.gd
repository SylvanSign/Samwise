extends Camera2D

export(int) var speed := 1000
export(float) var zoom_factor := 1.5

var panning := false
var selecting := false
var select_start: Vector2

func _process(delta: float) -> void:
	var input := Input.get_vector('left', 'right', 'up', 'down')
	position += input * speed * zoom * delta
	if selecting:
		update()

func _draw() -> void:
	if selecting:
		var rect := Rect2()
		rect.position = select_start
		rect.end = get_local_mouse_position()
		draw_rect(rect, Color.white, false)

func _unhandled_input(event: InputEvent) -> void:
	# zoom in
	if event.is_action_pressed('scroll_up'):
		zoom /= zoom_factor
	# zoom out
	elif event.is_action_pressed('scroll_down'):
		zoom *= zoom_factor
	elif event.is_action_pressed('middle_click'):
		panning = true
	elif event.is_action_released('middle_click'):
		panning = false
	elif panning and event is InputEventMouseMotion:
		position += event.relative * speed * zoom * get_process_delta_time()
		if select_start:
			update()
	elif event.is_action_pressed('click'):
		print('hi')
		selecting = true
		select_start = get_local_mouse_position()
	elif event.is_action_released('click'):
		if selecting:
			selecting = false
			update()
#	else:
#		return
#
#	get_tree().set_input_as_handled()
