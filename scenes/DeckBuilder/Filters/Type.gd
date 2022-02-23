extends OptionButton

const TYPES = {
	"All Types": "*",
	"Character": "Character",
	"Resource": "Resource",
	"Hazard": "Hazard",
	"Site": "Site",
}

func _ready() -> void:
	var id = 0
	for type in TYPES:
		add_item(type, id)
		set_item_metadata(id, TYPES[type])
		id += 1
