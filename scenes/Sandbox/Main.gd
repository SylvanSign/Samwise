extends Control

onready var player := $Player

func _ready() -> void:
	$Map.texture = Global.get_texture_from_cards_pck('map1.png')

func _on_Player_selection(rect: Rect2) -> void:
	rect = rect.abs()
	player.selected.clear()
	for card in $Cards.get_children():
		if rect.intersects((card as Control).get_rect_rotated()):
			card.selected = true
			player.selected[card] = null
		else:
			card.selected = false
