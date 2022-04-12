extends Node

# mer's size:
#var CARD_ASPECT := Vector2(570, 796).aspect()
# meccg.es gccg size:
var CARD_ASPECT := Vector2(420, 587).aspect()
var CARD_LENGTH := Vector2(420, 587).length()
var dragging_something := false

func get_texture_from_data(data: Dictionary) -> Texture:
	return get_texture_from_cards_pck(data.DCpath)


func get_texture_from_cards_pck(path: String) -> Texture:
	var image := Image.new()
	image.load('res://cards'.plus_file(path))
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	return texture
