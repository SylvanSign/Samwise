tool
extends VBoxContainer
class_name CardnumSection

var text: String setget set_text, get_text

func _ready() -> void:
	$Title/Label.text = name


func set_text(new_text: String) -> void:
	$List.text = new_text


func get_text() -> String:
	return $List.text


func for_export() -> void:
	$List.readonly = true
	$Title/Copy.visible = true


func for_import() -> void:
	$List.readonly = false
	$Title/Paste.visible = true


func _on_Copy_pressed() -> void:
	OS.clipboard = $List.text


func _on_Paste_pressed() -> void:
	$List.text = OS.clipboard
