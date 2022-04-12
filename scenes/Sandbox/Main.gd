extends Control

func _ready() -> void:
	$Map.texture = Global.get_texture_from_cards_pck('map1.png')

func _on_Player_selection(rect: Rect2) -> void:
	rect = rect.abs()
	for card in $Cards.get_children():
		if rect.intersects((card as Control).get_global_rect()):
			# TODO handle selection logic
			card.flip()
