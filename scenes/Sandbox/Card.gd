extends Control

var dragging := false
var dragging_offset: Vector2

func _ready() -> void:
	$TextureRect.texture = Global.get_texture_from_cards_pck('Wizards/Pallando.jpg')

func _process(delta: float) -> void:
	if dragging:
		rect_global_position = get_global_mouse_position() - dragging_offset

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed('click'):
		dragging = true
		dragging_offset = get_global_mouse_position() - rect_global_position
	elif event.is_action_released('click'):
		dragging = false
	else:
		return

	accept_event()
