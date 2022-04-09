extends TextureRect

var dragging := false
var dragging_offset: Vector2

func _ready() -> void:
	texture = Global.get_texture_from_cards_pck('Wizards/Pallando.jpg')

func _process(delta: float) -> void:
	if dragging:
		rect_position = get_global_mouse_position() - dragging_offset

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed('click'):
		dragging = true
		dragging_offset = get_global_mouse_position() - rect_position
	elif event.is_action_released('click'):
		dragging = false
	elif event.is_action_pressed('rotate_left'):
		rect_rotation -= 90
	elif event.is_action_pressed('rotate_right'):
		rect_rotation += 90
	else:
		return

	accept_event()

func _on_Card_mouse_entered() -> void:
	grab_focus()

func _on_Card_mouse_exited() -> void:
	release_focus()
