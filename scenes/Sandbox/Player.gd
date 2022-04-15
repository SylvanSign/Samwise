extends Camera2D

signal selection(rect)

export(int) var speed := 2000
export(float) var zoom_factor := 1.5

var panning := false
var dragging := false
var raised := false
var selecting := false
var select_start: Vector2
var selected := {}
var hovered: Node

func _ready() -> void:
	Events.connect('card_hovered', self, '_on_card_hovered')
	Events.connect('card_left', self, '_on_card_left')

func _on_card_hovered(card: Node) -> void:
	hovered = card
	if not selected.has(card) and not selecting:
		card.highlight()

func _on_card_left(card: Node) -> void:
	hovered = null
	if not (selected.has(card) or selecting):
		card.remove_highlight()

func _process(delta: float) -> void:
	var input := Input.get_vector('left', 'right', 'up', 'down')
	position += input * speed * zoom * delta
	if selecting:
		update()

func _draw() -> void:
	if selecting:
		draw_rect(local_selection_rect(), Color.white, false)

func local_selection_rect() -> Rect2:
	var rect := Rect2()
	rect.position = to_local(select_start)
	rect.end = get_local_mouse_position()
	return rect

func global_selection_rect() -> Rect2:
	var rect := Rect2()
	rect.position = select_start
	rect.end = get_global_mouse_position()
	return rect

#func _gui_input(event: InputEvent) -> void:
#	if event.is_action_pressed('click'):
#		dragging = true
#		dragging_offset = get_global_mouse_position() - rect_position
#	elif event.is_action_released('click'):
#		dragging = false
#	else:
#		player._unhandled_input(event)
#		return
#	accept_event()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		var relative := mouse_event.relative
		if panning:
			relative = mouse_event.relative * speed * zoom * get_process_delta_time() / 4
			position += relative
			if select_start:
				update()
		if dragging:
			if not raised:
				call_on_focused_cards('raise')
				raised = false
			call_on_focused_cards('move', [relative])
	elif event.is_action_pressed('click'):
		if hovered:
			dragging = true
		else:
			selecting = true
		select_start = get_global_mouse_position()
	elif event.is_action_released('click'):
		if selecting:
			emit_signal('selection', global_selection_rect())
			selecting = false
			update()
		else:
			dragging = false
			raised = false
	elif event.is_action_pressed('scroll_up'):
		zoom /= zoom_factor # zoom in
	elif event.is_action_pressed('scroll_down'):
		zoom *= zoom_factor # zoom out
	elif event.is_action_pressed('middle_click'):
		panning = true
	elif event.is_action_released('middle_click'):
		panning = false
	elif event.is_action_pressed('rotate_left'):
		call_on_focused_cards('rotate_left')
	elif event.is_action_pressed('rotate_right'):
		call_on_focused_cards('rotate_right')
	elif event.is_action_pressed('send_to_back'):
		call_on_focused_cards('send_to_back')
	elif event.is_action_pressed('bring_to_front'):
		call_on_focused_cards('bring_to_front')
	elif event.is_action_pressed('flip'):
		call_on_focused_cards('flip')
	else:
		return

	get_tree().set_input_as_handled()

func call_on_focused_cards(method: String, args := []) -> void:
	if hovered and not hovered in selected:
		hovered.callv(method, args)
	for card in selected:
		card.callv(method, args)
