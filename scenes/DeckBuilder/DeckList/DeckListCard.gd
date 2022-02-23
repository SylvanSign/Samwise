extends Control
class_name DeckListCard

signal zero_copies(spot)
signal dropped(data)
signal preview(card, texture)
signal end_preview
signal count_changed(card, change)
signal count_button_pressed(data)

export(NodePath) onready var count = get_node(count) as Button
export(NodePath) onready var title_art = get_node(title_art) as TextureRect

var previewable := false
var data := {}
var index: int
var num_copies := 0
var section: Control


func set_texture(new_texture: Texture) -> void:
	title_art.texture.atlas = new_texture
	previewable = true
	count.visible = true


func can_drop_data(_position: Vector2, _dd: Dictionary) -> bool:
	return true


func drop_data(_position: Vector2, dd: Dictionary) -> void:
	handle_drop(dd)


func get_drag_data(_position):
	if not data.empty():
		var drag_preview = TextureRect.new()
		drag_preview.texture = title_art.texture
		drag_preview.expand = true
		drag_preview.rect_size = title_art.rect_size
		drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT

		var parent_of_preview = Control.new()
		parent_of_preview.add_child(drag_preview)
		drag_preview.rect_position = -0.5 * drag_preview.rect_size
		set_drag_preview(parent_of_preview)
		return {
			type="deck_list_card",
			index=index,
			section=section,
			card=self,
			data=data,
		}


func handle_drop(dd: Dictionary) -> void:
	emit_signal("dropped", dd)


func increment_count() -> void:
	if room_for_more_copies():
		num_copies += 1
		if num_copies == max_for_card():
			count.disabled = true
		count.text = "*" if unique(data) else str(num_copies)
		emit_signal("count_changed", self, 1)


func room_for_more_copies() -> bool:
	return num_copies < max_for_card()


func max_for_card() -> int:
	# TODO: are there other "special cases" like this?
	if data.normalizedtitle == "black horse":
		return 9
	if data.Site.matchn("haven"):
		return 4
	return 1 if unique(data) else 3


func unique(card: Dictionary) -> bool:
	return card.Unique == "unique" and card.Secondary != "Avatar"


func decrement_count() -> void:
	if num_copies > 0:
		num_copies -= 1
		count.disabled = false
		emit_signal("count_changed", self, -1)
	if num_copies == 0:
		end_preview()
		emit_signal("zero_copies", index)
	else:
		count.text = str(num_copies)


func preview() -> void:
	if previewable:
		emit_signal("preview", count, title_art.texture.atlas)


func end_preview() -> void:
	emit_signal("end_preview")


func _on_Count_dropped(dd) -> void:
	handle_drop(dd)


func _on_TitleArt_dropped(dd) -> void:
	handle_drop(dd)


func _on_Count_mouse_entered() -> void:
	if room_for_more_copies():
		count.text = "+"
	preview()


func _on_Count_mouse_exited() -> void:
	if room_for_more_copies():
		count.text = str(num_copies)
	end_preview()


func _on_Count_pressed() -> void:
	emit_signal("count_button_pressed", data)


func _on_TitleArt_gui_input(event: InputEvent) -> void:
	if event.is_action_released("add_card"):
		decrement_count()


func _on_TitleArt_mouse_entered() -> void:
	preview()


func _on_TitleArt_mouse_exited() -> void:
	end_preview()

