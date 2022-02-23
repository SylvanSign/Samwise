extends OptionButton

const SETS = {
	"All Sets": "*",
	"The Wizards": "METW",
	"The Dragons": "METD",
	"Dark Minions": "MEDM",
	"The Lidless Eye": "MELE",
	"Against the Shadow": "MEAS",
	"The White Hand": "MEWH",
	"The Balrog": "MEBA",
}

func _ready() -> void:
	var id = 0
	for set in SETS:
		add_item(set, id)
		set_item_metadata(id, SETS[set])
		id += 1
