extends TextureRect


export(PackedScene) var CardScene: PackedScene
export(NodePath) onready var deck_list_card_drag_to_container = get_node(deck_list_card_drag_to_container) as Container
export(NodePath) onready var grid = get_node(grid) as GridContainer
export(NodePath) onready var current_page = get_node(current_page) as Label
export(NodePath) onready var total_pages = get_node(total_pages) as Label
export(NodePath) onready var left = get_node(left) as Button
export(NodePath) onready var right = get_node(right) as Button
export(NodePath) onready var zoom_out = get_node(zoom_out) as Button
export(NodePath) onready var zoom_in = get_node(zoom_in) as Button
export(NodePath) onready var preview = get_node(preview) as Preview
export(NodePath) onready var export_for_cardnum = get_node(export_for_cardnum) as ExportCardnumPopup
export(NodePath) onready var import_from_cardnum = get_node(import_from_cardnum) as ImportCardnumPopup
export(NodePath) onready var confirm_clear_deck = get_node(confirm_clear_deck) as Popup
export(NodePath) onready var search_by_name = get_node(search_by_name) as LineEdit
export(NodePath) onready var search_by_text = get_node(search_by_text) as LineEdit
export(NodePath) onready var search_by_quote = get_node(search_by_quote) as LineEdit
export(NodePath) onready var filter_by_set = get_node(filter_by_set) as OptionButton
export(NodePath) onready var filter_by_type = get_node(filter_by_type) as OptionButton

export(NodePath) onready var resources = get_node(resources) as DeckSection
export(NodePath) onready var hazards = get_node(hazards) as DeckSection
export(NodePath) onready var sideboard = get_node(sideboard) as DeckSection
export(NodePath) onready var characters = get_node(characters) as DeckSection
export(NodePath) onready var pool = get_node(pool) as DeckSection
export(NodePath) onready var fw_dc_sb = get_node(fw_dc_sb) as DeckSection
export(NodePath) onready var sites = get_node(sites) as DeckSection

export(NodePath) onready var loadDialog = get_node(loadDialog) as FileDialog
export(NodePath) onready var saveDialog = get_node(saveDialog) as FileDialog

const ZOOM_LEVELS := [
	[10, 11],
	[9, 11],
	[9, 10],
	[8, 9],
	[7, 8],
	[6, 7],
	[5, 6],
	[4, 5],
	[3, 4],
	[2, 3],
	[1, 1],
]
var cur_zoom_level: int = 9
var card_rows: int = ZOOM_LEVELS[cur_zoom_level][0]
var card_columns: int = ZOOM_LEVELS[cur_zoom_level][1]

onready var sections := [
	pool,
	characters,
	resources,
	hazards,
	sideboard,
	fw_dc_sb,
	sites,
]

onready var cards_per_page := card_rows * card_columns
var ALL_DATA: Array = load_json_file('res://cards.json')
var data: Array
var total_cards: int
var cur: int
var cur_card_for_zooming: int
var cur_section: DeckSection
var clearing_filters := false

func _ready() -> void:
	init_zoom_button_state()
	texture = Global.get_texture_from_cards_pck('background.png')
	set_drag_forwarding_recursively(deck_list_card_drag_to_container)
	grid.columns = card_columns
	initialize_grid()
	cur_section = resources
	cur_section.toggle_highlight()
	reset()


func set_drag_forwarding_recursively(control: Control) -> void:
	for child in control.get_children():
		if child is Control:
			child.set_drag_forwarding(self)
			set_drag_forwarding_recursively(child)


func reset() -> void:
	data = ALL_DATA
	clearing_filters = true
	search_by_name.clear()
	search_by_text.clear()
	search_by_quote.clear()
	filter_by_set.select(0)
	filter_by_type.select(0)
	search_by_name.grab_focus()
	show_results()
	clearing_filters = false


func show_results() -> void:
	cur = 0
	cur_card_for_zooming = 0
	total_cards = data.size()
	left.disabled = true
	populate_grid_textures()
	update_total_page_number()
	update_current_page_number()


func update_current_page_number() -> void:
	current_page.text = str(cur / cards_per_page + 1)


func update_total_page_number() -> void:
	total_pages.text = str(max(ceil(float(total_cards) / cards_per_page), 1))


func initialize_grid() -> void:
	var container_aspect := Global.CARD_ASPECT
	for spot in cards_per_page:
		var container = AspectRatioContainer.new()
		container.ratio = container_aspect
		container.size_flags_horizontal = SIZE_EXPAND_FILL
		container.size_flags_vertical = SIZE_EXPAND_FILL
		container.set_drag_forwarding(self)
		var card = CardScene.instance() as Card
		card.spot = spot
		container.add_child(card)
		grid.add_child(container)
		card.connect("add_card", self, "_on_Card_add_card", [card])
		card.connect("mouse_entered", self, "_on_Card_mouse_entered", [card])
		card.connect("mouse_exited", self, "_on_Card_mouse_exited")
		card.connect("dropped", self, "_on_Card_dropped")


func populate_grid_textures() -> void:
	for spot in cards_per_page:
		var card = grid.get_child(spot).get_child(0) as Card
		var previewing_this_spot = preview.spot == card.spot
		# check to see if we're out of results
		if cur + spot < total_cards:
			var card_data = data[cur + spot]
			card.data = card_data
			card.texture = Global.get_texture_from_data(card_data)
			card.previewable = true
			if previewing_this_spot:
				preview.visible = true
				preview.texture = card.texture
		else:
			card.data = {}
			card.texture = null
			card.previewable = false
			if previewing_this_spot:
				preview.hide()
	right.disabled = cur + cards_per_page >= total_cards


func can_drop_data(_position: Vector2, dd: Dictionary) -> bool:
	return can_drop_data_check(dd)


func can_drop_data_fw(_position: Vector2, dd: Dictionary, _from_control: Control) -> bool:
	return can_drop_data_check(dd)


func can_drop_data_check(dd: Dictionary) -> bool:
	return dd.type == "deck_list_card"


func drop_data(_position: Vector2, dd: Dictionary) -> void:
	drop_data_logic(dd)


func drop_data_fw(_position: Vector2, dd: Dictionary, _from_control: Control) -> void:
	drop_data_logic(dd)


func drop_data_logic(dd: Dictionary) -> void:
	cur_section.cards[dd.index].decrement_count()


func load_json_file(path):
	"""Loads a JSON file from the given res path and return the loaded JSON object."""
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var result_json = JSON.parse(text)
	if result_json.error == OK:
		var obj = result_json.result
		return obj
	else:
		push_error("yikers!")


func show_preview(card: Control, texture: Texture, left_only: bool, spot := -1, visible := true) -> void:
	if not Global.dragging_something:
		preview.setup(card, texture, left_only, spot, visible)


func _on_Card_mouse_entered(card: Card) -> void:
	show_preview(card, card.texture, false, card.spot, card.previewable)


func _on_Card_mouse_exited() -> void:
	preview.hide()
	preview.spot = -1


func _on_DeckSection_preview(card, texture) -> void:
	show_preview(card, texture, true)


func _on_DeckSection_end_preview() -> void:
	preview.hide(true)


func _on_Card_add_card(card: Card) -> void:
	preview.hide()
	cur_section.add_card(card.data)


func _on_Card_dropped(dd: Dictionary) -> void:
	drop_data_logic(dd)


func _on_Left_pressed() -> void:
	cur -= cards_per_page
	cur_card_for_zooming = cur
	update_current_page_number()
	if cur <= 0:
		left.disabled = true
	if cur + cards_per_page < total_cards:
		right.disabled = false
	populate_grid_textures()


func _on_Right_pressed() -> void:
	cur += cards_per_page
	cur_card_for_zooming = cur
	update_current_page_number()
	if cur > 0:
		left.disabled = false
	if cur + cards_per_page >= total_cards:
		right.disabled = true
	populate_grid_textures()


func _on_DeckBuilder_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right") and not right.disabled:
		_on_Right_pressed()
	elif event.is_action_pressed("ui_left") and not left.disabled:
		_on_Left_pressed()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("add_card"):
		Global.dragging_something = true
	elif event.is_action_released("add_card"):
		Global.dragging_something = false


func _on_FullScreen_pressed() -> void:
	OS.window_fullscreen = not OS.window_fullscreen
	search_by_name.grab_focus()


func run_query(node_to_focus: LineEdit = null) -> void:
	var name_query = "*" + search_by_name.text.strip_edges().to_lower() + "*"
	var text_query = "*" + search_by_text.text.strip_edges().to_lower() + "*"
	var quote_query = "*" + search_by_quote.text.strip_edges().to_lower() + "*"
	data = []
	for card in ALL_DATA:
		var card_text: Array = (card.Text as String).split('  \"', false, 1)
		var text: String = card_text[0]
		var quote: String = card_text[1] if card_text.size() > 1 else "*"
		if card.Set.matchn(filter_by_set.get_item_metadata(filter_by_set.selected)) \
			and card.Primary.matchn(filter_by_type.get_item_metadata(filter_by_type.selected)) \
			and card.normalizedtitle.matchn(name_query) \
			and text.matchn(text_query) \
			and quote.matchn(quote_query) \
			:
			data.append(card)
	if node_to_focus:
		node_to_focus.select_all()
	show_results()

func _on_Name_text_entered(_new_text: String) -> void:
	run_query(search_by_name)


func _on_Text_text_entered(_new_text: String) -> void:
	run_query(search_by_text)


func _on_Quote_text_entered(_new_text: String) -> void:
	run_query(search_by_quote)


func _on_Set_item_selected(_index: int) -> void:
	run_query()


func _on_Type_item_selected(_index: int) -> void:
	run_query()


func _on_ClearFiltersButton_pressed() -> void:
	reset()


func set_cur_section(section: DeckSection) -> void:
	cur_section.toggle_highlight()
	cur_section = section
	cur_section.toggle_highlight()


func _on_DeckSection_switch_tab_and_drop(drop_data) -> void:
	if not drop_data.has('Primary'):
		return

	match drop_data.Primary:
		"Character":
			set_cur_section(characters)
		"Resource":
			set_cur_section(resources)
		"Hazard":
			set_cur_section(hazards)
		"Site":
			set_cur_section(sites)
	cur_section.add_card(drop_data)


func _on_ExportForCardnum_pressed() -> void:
	for tab in sections:
		export_for_cardnum.set_decklist(tab.name, tab.get_list())
	export_for_cardnum.popup_centered_ratio()


func _on_SaveDialog_file_selected(path: String) -> void:
	var file := File.new()
	file.open(path, File.WRITE)
	for tab in sections:
		file.store_line(tab.name)
		file.store_line(tab.get_list() + '\n')
	file.close()


func _on_ImportFromCardnum_pressed() -> void:
	import_from_cardnum.clear()
	import_from_cardnum.popup_centered_ratio()


func _on_ImportCardnumPopup_import(deck: Dictionary) -> void:
	for tab in sections:
		tab.set_list(ALL_DATA, deck[tab.name])


func _on_LoadDialog_file_selected(path: String) -> void:
	var file := File.new()
	file.open(path, File.READ)

	var deck := {}
	while file.get_position() < file.get_len():
		var section_name = file.get_line()
		if section_name.empty():
			continue
		var section_list := PoolStringArray()
		while true:
			var line := file.get_line()
			if line.empty():
				break
			section_list.append(line)
		deck[section_name] = section_list.join('\n')

	file.close()

	for tab in sections:
		tab.set_list(ALL_DATA, deck[tab.name])


func _on_DeckBuilder_resized() -> void:
	for popup in [export_for_cardnum, import_from_cardnum]:
		if is_instance_valid(popup) and popup.visible:
			popup.popup_centered_ratio()
			break


func _on_DeckSection_count_changed(section: DeckSection, _card: DeckListCard, _change: int) -> void:
	# TODO deal with num_copies constraints across sections?
	set_cur_section(section)


func _on_DeckSection_highlight(section) -> void:
	set_cur_section(section)


func _on_ClearDeck_pressed() -> void:
	confirm_clear_deck.popup()


func _on_ConfirmClearDeck_confirmed() -> void:
	clear_deck()


func clear_deck() -> void:
	for section in sections:
		section.reset_state()


func _on_Name_text_changed(new_text: String) -> void:
	if new_text.empty() and not clearing_filters:
		run_query(search_by_name)


func _on_Text_text_changed(new_text):
	if new_text.empty() and not clearing_filters:
		run_query(search_by_text)


func _on_Quote_text_changed(new_text):
	if new_text.empty() and not clearing_filters:
		run_query(search_by_quote)


func _on_Load_pressed() -> void:
	loadDialog.invalidate()
	loadDialog.popup_centered_ratio()


func _on_Save_pressed() -> void:
	saveDialog.invalidate()
	saveDialog.popup_centered_ratio()


func _on_AllDecks_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path('user://decks'))


func init_zoom_button_state() -> void:
	maybe_disable_zoom_out()
	maybe_disable_zoom_in()


func maybe_disable_zoom_out() -> void:
	if cur_zoom_level == 0:
		zoom_out.disabled = true


func maybe_disable_zoom_in() -> void:
	if cur_zoom_level == ZOOM_LEVELS.size() - 1:
		zoom_in.disabled = true


func _on_ZoomOut_pressed() -> void:
	cur_zoom_level -= 1
	zoom_in.disabled = false
	maybe_disable_zoom_out()
	update_grid_zoom(ZOOM_LEVELS[cur_zoom_level])


func _on_ZoomIn_pressed() -> void:
	cur_zoom_level += 1
	zoom_out.disabled = false
	maybe_disable_zoom_in()
	update_grid_zoom(ZOOM_LEVELS[cur_zoom_level])


func update_grid_zoom(zoom_levels: Array)-> void:
	var rows: int = zoom_levels[0]
	var columns: int = zoom_levels[1]
	for child in grid.get_children():
		child.free()
	cards_per_page = rows * columns
	grid.columns = columns
	card_rows = rows
	card_columns = columns
	cur = (cur_card_for_zooming / cards_per_page) * cards_per_page
	update_current_page_number()
	update_total_page_number()
	initialize_grid()
	populate_grid_textures()
