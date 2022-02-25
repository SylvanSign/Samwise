.PHONY: export
export:
	godot --export "Linux/X11"
	godot --export "Windows Desktop"
	godot --export "Mac OSX"
	make zip

.PHONY: zip
zip: builds/linux.zip builds/mac.zip builds/windows.zip

builds/linux.zip: builds/linux
	rm -f builds/linux.zip
	cd builds && zip -r linux linux

builds/mac.zip: builds/mac
	rm -f builds/mac.zip
	cd builds && cp mac/samwise.zip mac.zip

builds/windows.zip: builds/windows
	rm -f builds/windows.zip
	cd builds && zip -r windows windows

cards.json: cards-dc.json
	node clean.js > cards.json

cards-dc.json:
	wget https://raw.githubusercontent.com/rezwits/cardnum/master/fdata/cards-dc.json -O cards-dc.json
