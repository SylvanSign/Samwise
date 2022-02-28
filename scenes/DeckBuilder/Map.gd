extends WindowDialog
class_name Map

onready var texture_rect := $ScrollContainer/TextureRect

var size: Vector2

func _ready() -> void:
	var texture := Global.get_texture_from_cards_pck('map1.png')
	texture_rect.texture = texture
	size = texture.get_size()


func show() -> void:
	.popup_centered_clamped(size, 0.9)
