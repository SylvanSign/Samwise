extends TextureRect

signal unhandled_input(event)

const BACK := 'metw-back.jpg'
const SITE_BACK := 'site-back.jpg'
onready var reference_rect := $ReferenceRect
onready var player := $'/root/Main/Player'

enum TYPE {
	SITE,
	OTHER,
}

export var path := 'Wizards/SamGamgee.jpg'
export var type := TYPE.OTHER

var dragging := false
var dragging_offset: Vector2
var flipped := false
var selected := false setget set_selected

func set_selected(val: bool) -> void:
	selected = val
	if val:
		highlight(Color.yellow)
	else:
		remove_highlight()

func _ready() -> void:
	texture = Global.get_texture_from_cards_pck(path)
	reference_rect.rect_size = rect_size

func _process(delta: float) -> void:
	if dragging:
		rect_position = get_global_mouse_position() - dragging_offset

func _gui_input(event: InputEvent) -> void:
	player._unhandled_input(event)
	accept_event()

func rotate_left() -> void:
	rect_rotation -= 90

func rotate_right() -> void:
	rect_rotation += 90

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
			remove_highlight()
			node.grab_focus()
			node.highlight()
			break

func flip() -> void:
	if flipped:
		texture = Global.get_texture_from_cards_pck(path)
	else:
		var path := SITE_BACK if type == TYPE.SITE else BACK
		texture = Global.get_texture_from_cards_pck(path)
	flipped = not flipped

func highlight(color := Color.white) -> void:
	reference_rect.border_color = color
	reference_rect.visible = true

func remove_highlight() -> void:
	reference_rect.visible = false

func _on_Card_mouse_entered() -> void:
	grab_focus()
	Events.emit_signal('card_hovered', self)

func _on_Card_mouse_exited() -> void:
	release_focus()
	Events.emit_signal('card_left', self)
