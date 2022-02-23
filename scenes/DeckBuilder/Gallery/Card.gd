extends TextureRect
class_name Card

signal add_card
signal dropped(data)

var spot: int
var previewable := false
var data := {}

func get_drag_data(_position):
	if not data.empty():
		var preview = TextureRect.new()
		preview.texture = texture
		preview.expand = true
		preview.rect_size = rect_size
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT

		var parent_of_preview = Control.new()
		parent_of_preview.add_child(preview)
		preview.rect_position = -0.5 * preview.rect_size
		set_drag_preview(parent_of_preview)
		return {
			type="card",
			data=data,
		}


func can_drop_data(_position: Vector2, dd: Dictionary) -> bool:
	return dd.type == "deck_list_card"


func drop_data(_position: Vector2, dd: Dictionary) -> void:
	emit_signal("dropped", dd)


func _on_Card_gui_input(event: InputEvent) -> void:
	if event.is_action_released("add_card"):
		emit_signal("add_card")
