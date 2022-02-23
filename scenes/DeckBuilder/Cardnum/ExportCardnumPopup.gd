extends CardnumPopup
class_name ExportCardnumPopup


func _ready() -> void:
	for section in sections:
		section.for_export()


func set_decklist(section: String, text: String) -> void:
	(sections_container.find_node(section) as CardnumSection).text = text


func _on_Close_pressed() -> void:
	hide()
