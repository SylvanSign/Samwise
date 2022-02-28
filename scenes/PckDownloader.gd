extends Control

onready var http_request := $HTTPRequest
onready var timer := $Timer
onready var label := $MarginContainer/VBoxContainer/Label
onready var message := $MarginContainer/VBoxContainer/Message
onready var download_button := $MarginContainer/VBoxContainer/DownloadButton

const CARDS_PCK := 'user://cards.pck'
const CARDS_RES_LOCATION := 'res://cards'
const BUNDLED_DECKS := 'res://decks/'
const CHALLENGE_DECKS := 'user://decks/challenge'
const GIT_ZIPPED := 'user://cards.zip'
const GIT_UNZIPPED := 'user://cards'
const GIT_ASSET_DIR_PATH := 'user://cards/MeCCG-Windows-EN-master/metw/graphics/Metw'

func _ready() -> void:
	setup_decks_dir()
	check_for_cards()


func setup_decks_dir() -> void:
	var dir := Directory.new()
	if dir.dir_exists(CHALLENGE_DECKS):
		return

	if OK != dir.open(BUNDLED_DECKS):
		printerr('Error opening ', BUNDLED_DECKS)
		return

	dir.make_dir_recursive(CHALLENGE_DECKS)
	dir.list_dir_begin(true, true)
	var deck = dir.get_next()
	while deck != "":
		if OK != dir.copy(BUNDLED_DECKS.plus_file(deck), CHALLENGE_DECKS.plus_file(deck)):
			printerr('Error copying ', deck)
		deck = dir.get_next()


func check_for_cards() -> void:
	if ProjectSettings.load_resource_pack(CARDS_PCK):
		get_tree().change_scene("res://scenes/DeckBuilder/DeckBuilder.tscn")
	else:
		label.text = 'Missing card assets. Would you like to download them?'
		message.visible = true
		download_button.visible = true


func _on_DownloadButton_pressed() -> void:
	download_button.visible = false
	if Directory.new().file_exists('user://cards.zip'):
		print('already downloaded cards.zip, so need to unzip...')
		_on_HTTPRequest_request_completed(0, 200, [], []) # TODO this is a bit ugly...
	else:
		label.text = 'Downloading cards. This may take a while...'
		http_request.request('https://github.com/semaex/MeCCG-Windows-EN/archive/refs/heads/master.zip')


func _on_HTTPRequest_request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray) -> void:
	if response_code != 200:
		var err_msg := 'Got HTTP response ' + str(response_code)
		printerr(err_msg)
		OS.alert(err_msg, 'Bad HTTP response')
		get_tree().quit(1)
	else:
		if Directory.new().file_exists('user://cards'):
			print('files already unzipped')
		else:
			label.text = 'Unzipping files...'
			yield(get_tree().create_timer(0.3), "timeout")

			match OS.get_name():
				'Windows':
					pass
				_:
					if !run('unzips '+fs_path('user://cards.zip')+' -d '+fs_path('user://cards')):
						OS.alert("Please install 'unzip' or manually unzip 'cards.zip' and run again!", 'Failed to unzip!')
						OS.shell_open(OS.get_user_data_dir())
						get_tree().quit(1)

			label.text = 'Building pck file from cards...'
			yield(get_tree().create_timer(0.3), "timeout")
		pack()



func pack() -> void:
	var packer = PCKPacker.new()
	assert(OK == packer.pck_start(CARDS_PCK))
	pack_helper(packer, GIT_ASSET_DIR_PATH, CARDS_RES_LOCATION)
	assert(OK == packer.flush(true))
	rm_rf(fs_path(GIT_ZIPPED))
	rm_rf(fs_path(GIT_UNZIPPED))
	check_for_cards()


func pack_helper(packer: PCKPacker, fs_path: String, pack_path: String) -> void:
	var dir = Directory.new()
	assert(OK == dir.open(fs_path))
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = fs_path.plus_file(file_name)
		var resource_path = pack_path.plus_file(file_name)
		if dir.current_is_dir():
			pack_helper(packer, file_path, resource_path)
		else:
			assert(OK == packer.add_file(resource_path, file_path))
		file_name = dir.get_next()


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


func run(command: String) -> bool:
	var args := Array(command.split(' ', false))
	var path = args.pop_front()

	var output = []
	var exit_code := OS.execute(path, args, true, output, true)
	if exit_code != OK:
		printerr('Command '+command+' failed with code '+str(exit_code))
		printerr(output)
		return false
	else:
		return true


func _on_GitMessage_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)
