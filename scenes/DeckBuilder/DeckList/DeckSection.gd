extends Container
class_name DeckSection

signal switch_tab_and_drop(data)
signal count_changed(section, card, change)
signal highlight(section)
signal preview(card, texture)
signal end_preview

export(int) var size := 50
export(Array, String) var primary: Array
export(NodePath) onready var color_rect = get_node(color_rect) as ColorRect
export(NodePath) onready var grid = get_node(grid) as VBoxContainer
export(NodePath) onready var count_label = get_node(count_label) as Label
export(NodePath) onready var max_label = get_node(max_label) as Label
export(NodePath) onready var label = get_node(label) as Label
export(PackedScene) var DeckListCardScene: PackedScene

onready var highlighted := false

var max_count: int setget set_max_count
var count := 0 setget set_count

var cards: Array


func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_window_resized")
	label.text = name
	set_drag_forwarding_recursively(self)
	reset_state()


func set_drag_forwarding_recursively(control: Control) -> void:
	for child in control.get_children():
		if child != grid:
			child.set_drag_forwarding(self)
			set_drag_forwarding_recursively(child)


func reset_state() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
	set_max_count(size)
	cards.clear()
	set_count(0)


func toggle_highlight() -> void:
	highlighted = not highlighted
	if highlighted:
		$Highlight.visible = true
	else:
		$Highlight.hide()


func make_new_card() -> DeckListCard:
	var deck_list_card = DeckListCardScene.instance() as DeckListCard
	deck_list_card.section = self
	deck_list_card.connect("dropped", self, "drop_data_logic")
	deck_list_card.connect("zero_copies", self, "_on_DeckListCard_zero_copies")
	deck_list_card.connect("preview", self, "_on_DeckListCard_preview")
	deck_list_card.connect("end_preview", self, "_on_DeckListCard_end_preview")
	deck_list_card.connect("count_changed", self, "_on_DeckListCard_count_changed")
	deck_list_card.connect("count_button_pressed", self, "_on_DeckListCard_count_button_pressed")
	reset_min_size(deck_list_card)
	grid.add_child(deck_list_card)
	return deck_list_card


func get_list() -> String:
	var list := PoolStringArray()
	var cards_so_far := 0
	for i in count:
		var card = cards[i]
		var num_copies = card.num_copies
		cards_so_far += num_copies
		var line = "{num_copies} {title}".format({
			num_copies=num_copies,
			title=card.data.fullCode,
		})
		list.append(line)
		if cards_so_far == count:
			break # we might have more "cards" indices, but they'll be empty placeholders
	return list.join("\n")


func set_list(card_data: Array, list: String) -> void:
	var card_codes := list.strip_edges().split("\n", false)
	var parsed_copies_and_code = {}
	for card_code in card_codes:
		var copies_and_code = card_code.split(" ", false, 1)
		var copies = int(copies_and_code[0].strip_edges())
		var code = copies_and_code[1].strip_edges()
		parsed_copies_and_code[code] = copies
	var codes = parsed_copies_and_code.keys()

	if not codes.empty():
		for child in grid.get_children():
			child.queue_free()
		reset_state()
		for card in card_data:
			if card.fullCode in codes:
				for _times in parsed_copies_and_code[card.fullCode]:
					add_card(card, false)


func set_count(new_count: int) -> void:
	count = new_count
	count_label.text = str(new_count)


func set_max_count(new_count: int) -> void:
	max_count = new_count
	max_label.text = str(new_count)


func can_drop_data(_position: Vector2, dd: Dictionary) -> bool:
	return drop_data_check(dd)


func can_drop_data_fw(_position: Vector2, dd: Dictionary, _from_control: Control) -> bool:
	return drop_data_check(dd)


func drop_data_check(_dd: Dictionary) -> bool:
	return true


func drop_data(_position: Vector2, dd: Dictionary) -> void:
	drop_data_logic(dd)


func drop_data_fw(_position: Vector2, dd: Dictionary, _from_control: Control) -> void:
	drop_data_logic(dd)


func drop_data_logic(dd: Dictionary) -> void:
	if not dd.has("section"):
		add_card(dd.data, false)
	elif dd.section.name != name:
		if card_belongs(dd.data):
			dd.card.decrement_count()
			add_card(dd.data, false)


func card_belongs(data: Dictionary) -> bool:
	return data.has('Primary') and primary.has(data.Primary)


func add_card(data: Dictionary, signals_enabled := true) -> void:
	if card_belongs(data):
		var index = cards.bsearch_custom({ data=data }, self, "compare")
		if count < max_count:
			var card := (cards[index] as DeckListCard) if index < cards.size() else null
			if card and card.data.normalizedtitle == data.normalizedtitle:
				card.increment_count()
			else:
				var deck_list_card := make_new_card()
				deck_list_card.set_texture(Global.get_texture_from_data(data))
				deck_list_card.data = data
				deck_list_card.index = index
				deck_list_card.increment_count()
				cards.insert(index, deck_list_card)
				reorder_deck_section_display()
		emit_signal("count_changed", self, data, 1)
	elif signals_enabled:
		emit_signal("switch_tab_and_drop", data)


func remove_card(index: int) -> void:
	var card := (cards[index] as DeckListCard)
	cards.remove(index)
	card.queue_free()
	reorder_deck_section_display()


func reorder_deck_section_display() -> void:
	for child in grid.get_children():
		grid.remove_child(child)

	for index in cards.size():
		cards[index].index = index
		grid.add_child(cards[index])


func compare(a, b) -> bool:
	if a.data.empty():
		return false
	elif b.data.empty():
		return true
	return a.data.normalizedtitle < b.data.normalizedtitle


func _on_DeckListCard_zero_copies(index: int) -> void:
	remove_card(index)


func _on_DeckListCard_preview(card: Control, texture: Texture) -> void:
	emit_signal("preview", card, texture)


func _on_DeckListCard_end_preview() -> void:
	emit_signal("end_preview")


func _on_DeckListCard_count_changed(card: DeckListCard, change: int) -> void:
	set_count(count + change)
	emit_signal("count_changed", self, card, change)


func _on_DeckListCard_count_button_pressed(data: Dictionary) -> void:
	add_card(data)


func _on_window_resized() -> void:
	for child in grid.get_children():
		child.rect_min_size = Vector2.ZERO
	yield(get_tree().create_timer(0), "timeout")
	for card in cards:
		reset_min_size(card)


func reset_min_size(card: DeckListCard) -> void:
	var x = rect_size.x - 10
	card.rect_min_size.x = x - 10
	card.rect_min_size.y = x / card.ratio


func _on_DeckSection_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("add_card"):
		emit_signal("highlight", self)
	accept_event()
