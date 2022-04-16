extends TextureRect
class_name SandboxCard

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

func _gui_input(event: InputEvent) -> void:
	player._unandled_gui_input(event, get_rotation())
	accept_event()

func get_rect_rotated() -> Rect2:
	return _get_rect_rotated_helper('get_rect', rect_position)

func get_global_rect_rotated() -> Rect2:
	return _get_rect_rotated_helper('get_global_rect', rect_global_position)

func _get_rect_rotated_helper(default: String, pos: Vector2) -> Rect2:
	if fmod(rect_rotation, 180) == 0:
		return call(default)
	else:
		var pos_diff := (rect_size.y - rect_size.x) / 2
		var new_pos := pos + Vector2(-pos_diff, pos_diff)
		var new_size := Vector2(rect_size.y, rect_size.x)
		return Rect2(new_pos, new_size)

func move(relative: Vector2) -> void:
	rect_position += relative

func rotate_left() -> void:
	rect_rotation = fmod(rect_rotation - 90, 360)

func rotate_right() -> void:
	rect_rotation = fmod(rect_rotation + 90, 360)

func bring_to_front() -> void:
	var parent := get_parent()
	raise()

func send_to_back() -> void:
	var parent := get_parent()
	parent.move_child(self, 0)

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
	Events.emit_signal('card_hovered', self)

func _on_Card_mouse_exited() -> void:
	Events.emit_signal('card_left', self)
