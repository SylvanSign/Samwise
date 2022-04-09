extends Control

func _ready() -> void:
	$Map.texture = Global.get_texture_from_cards_pck('map1.png')
