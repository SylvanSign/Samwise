extends TextureRect

const BACK := 'metw-back.jpg'
const SITE_BACK := 'site-back.jpg'

enum TYPE {
	SITE,
	OTHER,
}

export(String) var path := 'Wizards/SamGamgee.jpg'
export(TYPE) var type := TYPE.OTHER

var dragging := false
var dragging_offset: Vector2
var flipped := false
var selected := false setget set_selected

func set_selected(val: bool) -> void:
	selected = val
	$ReferenceRect.visible = val

func _ready() -> void:
	texture = Global.get_texture_from_cards_pck(path)
	$ReferenceRect.rect_size = rect_size

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
	elif event.is_action_pressed('flip'):
		flip()
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

func flip() -> void:
	if flipped:
		texture = Global.get_texture_from_cards_pck(path)
	else:
		var path := SITE_BACK if type == TYPE.SITE else BACK
		texture = Global.get_texture_from_cards_pck(path)
	flipped = not flipped

func _on_Card_mouse_entered() -> void:
	grab_focus()

func _on_Card_mouse_exited() -> void:
	release_focus()
