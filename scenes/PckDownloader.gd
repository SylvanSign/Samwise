extends Control

onready var http_request := $HTTPRequest
onready var timer := $Timer
onready var label := $MarginContainer/VBoxContainer/Label
onready var message := $MarginContainer/VBoxContainer/Message
onready var download_button := $MarginContainer/VBoxContainer/DownloadButton


func _ready() -> void:
	setup_decks_dir()
	check_for_cards()


func setup_decks_dir() -> void:
	var dir := Directory.new()
	if dir.dir_exists('user://decks/challenge'):
		return

	if OK != dir.open('res://decks/'):
		printerr('Error opening res://decks/')
		return

	dir.make_dir_recursive('user://decks/challenge')
	dir.list_dir_begin(true, true)
	var deck = dir.get_next()
	while deck != "":
		print('trying to copy ', deck)
		if OK != dir.copy('res://decks'.plus_file(deck), 'user://decks/challenge'.plus_file(deck)):
			printerr('Error copying ', deck)
		deck = dir.get_next()


func pack() -> void:
	var packer = PCKPacker.new()
	handle_error(packer.pck_start('user://cards.pck'))
	pack_helper(packer, 'metw/graphics/Metw', 'res://cards')
	handle_error(packer.flush(true))
	rm_rf(fs_path('user://cards'))
	check_for_cards()


func handle_error(error: int) -> void:
	if error != OK:
		printerr(error)
		print_stack()
		OS.alert("Got a fatal error! Please consult the log that's about to open...")
		OS.shell_open(ProjectSettings.globalize_path('user://logs/godot.log')) # TODO remove this, only useful for debugging
		get_tree().quit(1)


func pack_helper(packer: PCKPacker, fs_path: String, pack_path: String) -> void:
	var dir = Directory.new()
	handle_error(dir.open(fs_path))
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = fs_path.plus_file(file_name)
		var resource_path = pack_path.plus_file(file_name)
		if dir.current_is_dir():
			pack_helper(packer, file_path, resource_path)
		else:
			handle_error(packer.add_file(resource_path, file_path))
		file_name = dir.get_next()



func check_for_cards() -> void:
#	OS.shell_open(OS.get_user_data_dir()) # TODO remove this, only useful for debugging
	if ProjectSettings.load_resource_pack("user://cards.pck"):
		get_tree().change_scene("res://scenes/DeckBuilder/DeckBuilder.tscn")
	else:
		label.text = 'Missing card assets. Would you like to download them?'
		message.visible = true
		download_button.visible = true


func rm_rf(path: String) -> void:
	match OS.get_name():
		'Windows':
			run('rd /S /Q '+path)
		_:
			run('rm -rf '+path)


func fs_path(path: String) -> String:
	var globalized_path = ProjectSettings.globalize_path(path)
	match OS.get_name():
		'Windows':
			return globalized_path.replace('/', '\\')
		_:
			return globalized_path


func run(command: String) -> void:
	var args := Array(command.split(' ', false))
	var path = args.pop_front()

	var output = []
	var exit_code := OS.execute(path, args, true, output, true)
	if exit_code != OK:
		printerr('Command '+command+' failed with code '+str(exit_code))
		printerr(output)


func _on_DownloadButton_pressed() -> void:
	download_button.visible = false
	label.text = 'Downloading cards. This may take a while...'
#	http_request.download_file = 'user://cards.zip'
#	http_request.request('https://github.com/semaex/MeCCG-Windows-EN/archive/refs/heads/master.zip')
	_on_HTTPRequest_request_completed(0, 0, [], []) # TODO don't explicitly call this


func _on_GitMessage_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	label.text = 'Unzipping files...'
	yield(get_tree(), "idle_frame")

	match OS.get_name():
		'Windows':
			run('rd /S /Q '+path)
		_:
			unix_like_unzip()

	label.text = 'Building pck file from cards...'
	yield(get_tree(), "idle_frame")
	pack()

func unix_like_unzip() -> void:
	var output = []
	var exit_code := OS.execute('unzip', [], true, output, true)
	if exit_code != OK:
		printerr('unzip check failed with code '+str(exit_code))
		printerr(output)
		OS.alert("Please install 'unzip' or manually unzip 'cards.zip' and run again!", 'Missing unzip!')
		OS.shell_open(OS.get_user_data_dir())
		get_tree().quit(1)
