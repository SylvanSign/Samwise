extends TextureRect

var dragging := false
var dragging_offset: Vector2

export(String) var path := 'Wizards/SamGamgee.jpg'

func _ready() -> void:
	texture = Global.get_texture_from_cards_pck(path)

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
	elif event.is_action_pressed('send_to_back'):
		send_to_back()
	elif event.is_action_pressed('bring_to_front'):
		bring_to_front()
	else:
		return
	accept_event()

func bring_to_front() -> void:
	var parent := get_parent()
	raise()

func send_to_back() -> void:
	var parent := get_parent()
	parent.move_child(self, 0)
	# TODO is there a better way to make "cards above this one" grab focus?
	var mousePos =  get_global_mouse_position()
	var children = get_parent().get_children()
	children.invert()
	for node in children:
		if node.get_global_rect().has_point(mousePos):
			print(node.path)
			node.grab_focus()
			break

func _on_Card_mouse_entered() -> void:
	grab_focus()

func _on_Card_mouse_exited() -> void:
	release_focus()
