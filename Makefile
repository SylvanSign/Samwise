.PHONY: export
export:
	godot --export "Linux/X11"
	godot --export "Windows Desktop"
	godot --export "Mac OSX"
	make zip

.PHONY: zip
zip: builds/linux.zip builds/mac.zip builds/windows.zip

builds/linux.zip: builds/linux
	zip -r builds/linux builds/linux

builds/mac.zip: builds/mac
	cp builds/mac/samwise.zip builds/mac.zip

builds/windows.zip: builds/windows
	zip -r builds/windows builds/windows

cards.json: cards-dc.json
	node clean.js > cards.json

cards-dc.json:
	wget https://raw.githubusercontent.com/rezwits/cardnum/master/fdata/cards-dc.json -O cards-dc.json
