extends Control

func _ready() -> void:
	$TextureRect.texture = Global.get_texture_from_cards_pck('Wizards/Gandalf.jpg')
