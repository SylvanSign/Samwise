extends WindowDialog
class_name CardnumPopup

onready var sections_container := $MarginContainer/VBoxContainer
onready var sections = [
	$MarginContainer/VBoxContainer/TopRow/Resources,
	$MarginContainer/VBoxContainer/TopRow/Hazards,
	$MarginContainer/VBoxContainer/TopRow/Sideboard,
	$MarginContainer/VBoxContainer/BottomRow/Characters,
	$MarginContainer/VBoxContainer/BottomRow/Pool,
	$"MarginContainer/VBoxContainer/BottomRow/VBoxContainer/FW-DC-SB",
	$MarginContainer/VBoxContainer/BottomRow/VBoxContainer/Sites,
]
