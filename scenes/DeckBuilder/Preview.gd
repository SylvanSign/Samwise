extends TextureRect
class_name Preview

#const SCALE = 0.75
const SCALE = 0.75

var spot := -1
onready var aspect := Global.CARD_ASPECT

func setup(card: Control, card_texture: Texture, left_only: bool, card_spot := -1) -> void:
	texture = card_texture
	spot = card_spot
	var bounds := get_viewport().size
	var preview_y = bounds.y * SCALE
	rect_size = Vector2(preview_y * Global.CARD_ASPECT, preview_y).clamped(texture.get_size().length())

	rect_position.y = card.rect_global_position.y + card.rect_size.y / 2 - rect_size.y / 2

	var x_max = bounds.x - rect_size.x
	if left_only or x_max < card.rect_global_position.x + card.rect_size.x:
		rect_position.x = card.rect_global_position.x - rect_size.x
	else:
		rect_position.x = card.rect_global_position.x + card.rect_size.x
	rect_position.y = clamp(rect_position.y, 0, bounds.y - rect_size.y)
