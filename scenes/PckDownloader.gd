extends Control

onready var http_request := $HTTPRequest
onready var timer := $Timer
onready var label := $MarginContainer/VBoxContainer/Label
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

	var error := dir.open(BUNDLED_DECKS)
	if error:
		printerr('Error: ', error, ' Failed to dir.open(', BUNDLED_DECKS, ')')
		return

	error = dir.make_dir_recursive(CHALLENGE_DECKS)
	if error:
		printerr('Error: ', error, ' Failed to dir.make_dir_recursive(', CHALLENGE_DECKS, ')')
		return

	error = dir.list_dir_begin(true, true)
	if error:
		printerr('Error: ', error, ' Failed to dir.list_dir_begin(true, true)')
		return

	var deck = dir.get_next()
	while deck != "":
		error = dir.copy(BUNDLED_DECKS.plus_file(deck), CHALLENGE_DECKS.plus_file(deck))
		if error:
			printerr('Error: ', error, ' dir.copy(', BUNDLED_DECKS.plus_file(deck), ', ', CHALLENGE_DECKS.plus_file(deck), ')')
		deck = dir.get_next()


func report_error_and_quit(error: String) -> void:
	printerr(error)
	OS.alert(error)
	OS.shell_open(OS.get_user_data_dir())
	get_tree().quit(1)


func check_for_cards() -> void:
	if ProjectSettings.load_resource_pack(CARDS_PCK):
		get_tree().change_scene("res://scenes/DeckBuilder/DeckBuilder.tscn")
	else:
		var dir := Directory.new()
		var error := dir.open('user://')
		if error:
			report_error_and_quit('Error: '+str(error)+" Failed to dir.open('user://')")
		else:
			if dir.dir_exists('cards'):
				print('files already downloaded and unzipped')
				pack()
			elif dir.file_exists('cards.zip'):
				print('already downloaded cards.zip, but need to unzip...')
				unzip()
			else:
				print('need to download cards, so prompting the user...')
				label.text = 'Missing card assets. Would you like to download them?'
				download_button.visible = true


func _on_DownloadButton_pressed() -> void:
	download_button.visible = false
	label.text = 'Downloading cards. This may take a while...'
	http_request.request('https://github.com/semaex/MeCCG-Windows-EN/archive/refs/heads/master.zip')


func _on_HTTPRequest_request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray) -> void:
	if response_code != 200:
		var error := 'Got HTTP response ' + str(response_code)
		report_error_and_quit(error)
	else:
		unzip()


func unzip() -> void:
	label.text = 'Unzipping files...'
	yield(get_tree().create_timer(0.3), "timeout")

	match OS.get_name():
		'Windows':
			if !run('cmd.exe', ['/C cd '+fs_path('user://')+' && tar -xf cards.zip && mkdir cards && move MeCCG-Windows-EN-master cards']) \
				and !run('powershell.exe', ['-Command', '"Expand-Archive -Force '+fs_path('user://cards.zip')+' '+fs_path('user://cards') + '"']):
				report_error_and_quit("Please manually extract 'cards.zip' to 'cards\', then run Samwise again!")
		_:
			if !run('unzip', [fs_path('user://cards.zip'), '-d', fs_path('user://cards')]):
				report_error_and_quit("Please install 'unzip' or manually extract 'cards.zip' to 'cards/', then run Samwise again!")

	pack()




func pack() -> void:
	label.text = 'Building pck file from cards...'
	yield(get_tree().create_timer(0.3), "timeout")

	var packer := PCKPacker.new()

	var error := packer.pck_start(CARDS_PCK)
	if error:
		report_error_and_quit('Error: '+str(error)+'Failed to packer.pck_start('+CARDS_PCK+')')
		return

	pack_helper(packer, GIT_ASSET_DIR_PATH, CARDS_RES_LOCATION)

	error = packer.flush(true)
	if error:
		report_error_and_quit('Error: '+str(error)+'Failed to packer.flush(true)')
		return

	rm(fs_path(GIT_ZIPPED))
	rm_rf(fs_path(GIT_UNZIPPED))
	check_for_cards()



func pack_helper(packer: PCKPacker, fs_path: String, pack_path: String) -> void:
	var dir := Directory.new()

	var error := dir.open(fs_path)
	if error:
		report_error_and_quit('Error: '+str(error)+' Failed to dir.open('+fs_path+')')
		return

	error = dir.list_dir_begin(true, true)
	if error:
		report_error_and_quit('Error: '+str(error)+' Failed to dir.list_dir_begin(true, true)')
		return

	var file_name := dir.get_next()
	while file_name != "":
		var file_path := fs_path.plus_file(file_name)
		var resource_path := pack_path.plus_file(file_name)
		if dir.current_is_dir():
			pack_helper(packer, file_path, resource_path)
		else:
			error = packer.add_file(resource_path, file_path)
			if error:
				report_error_and_quit('Error: '+str(error)+' Failed to packer.add_file('+resource_path+', '+file_path+')')
				return
		file_name = dir.get_next()


func rm(path: String) -> void:
	match OS.get_name():
		'Windows':
			run('del', [path])
		_:
			run('rm', ['-f', path])


func rm_rf(path: String) -> void:
	match OS.get_name():
		'Windows':
			run('rd', ['/S', '/Q', path])
		_:
			run('rm', ['-rf', path])


func fs_path(path: String) -> String:
	var globalized_path = ProjectSettings.globalize_path(path)
	match OS.get_name():
		'Windows':
			return globalized_path.replace('/', '\\')
		_:
			return globalized_path


func run(path: String, args: Array) -> bool:
	print('Running ', path, ' ', args)
	var output = []
	var exit_code := OS.execute(path, args, true, output, true)
	if exit_code != OK:
		printerr('Command ', path, ' ', args, ' failed with code ', exit_code)
		printerr(output)
		return false
	else:
		return true


func _on_GitMessage_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)
