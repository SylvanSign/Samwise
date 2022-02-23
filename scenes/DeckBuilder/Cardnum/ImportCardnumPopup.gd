extends CardnumPopup
class_name ImportCardnumPopup

signal import(deck)

func _ready() -> void:
	for section in sections:
		section.for_import()


func clear() -> void:
	for section in sections:
		section.set_text("")


func _on_Import_pressed() -> void:
	var deck := {}
	for section in sections:
		deck[section.name] = section.text
	emit_signal("import", deck)
	hide()
