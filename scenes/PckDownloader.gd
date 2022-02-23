extends MarginContainer

onready var timer := $Timer
onready var label := $Control/Label
onready var download_button := $Control/DownloadButton


func _ready() -> void:
	check_for_cards()


func pack(assets_path: String) -> void:
	var packer = PCKPacker.new()
	handle_error(packer.pck_start('user://cards.pck'))
	pack_helper(packer, assets_path, 'res://cards')
	handle_error(packer.flush(true))
	rm_rf(ProjectSettings.globalize_path('user://cards'))
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
		download_button.visible = true


func git_clone_assets_from_meccges() -> String:
	return git_clone_repo('https://github.com/semaex/MeCCG-Windows-EN', 'metw/graphics/Metw/')


func git_clone_assets_from_mer() -> String:
	return git_clone_repo('https://github.com/usmcgeek/mer', 'data/classic_style/')


func git_clone_repo(repo: String, assets_path: String) -> String:
	var user_cards := ProjectSettings.globalize_path('user://cards')
	var user_cards_git_dir := ProjectSettings.globalize_path('user://cards/.git')
	run('git clone '+repo+' --no-checkout ' + user_cards + ' --depth 1')
	run('git --git-dir '+user_cards_git_dir+' --work-tree '+user_cards+' sparse-checkout init --cone')
	run('git --git-dir '+user_cards_git_dir+' sparse-checkout set '+assets_path)
	run('git --git-dir '+user_cards_git_dir+' --work-tree '+user_cards+' checkout')
	rm_rf(user_cards_git_dir)
	return 'user://cards/'+assets_path


func rm_rf(path: String) -> void:
	match OS.get_name():
		'Windows':
			run('rd /S /Q '+path)
		_:
			run('rm -rf '+path)


func run(command: String) -> void:
	var args := Array(command.split(' ', false))
	var path = args.pop_front()

	var output = []
	handle_error(OS.execute(path, args, true, output, true))


func _on_Timer_timeout() -> void:
	download_assets()


func _on_DownloadButton_pressed() -> void:
	download_button.disabled = true
	label.text = 'Downloading cards. This may take a while...'
	timer.start()


func download_assets() -> void:
	rm_rf(ProjectSettings.globalize_path('user://cards'))
	# TODO mer has higher quality, larger dimensions. But git clone takes forever and
	# seems to often fail...
	# var assets_path = git_clone_assets_from_mer()
	var assets_path = git_clone_assets_from_meccges()
	label.text = 'Building pck file from cards...'
	yield(get_tree(), "idle_frame")
	pack(assets_path)
