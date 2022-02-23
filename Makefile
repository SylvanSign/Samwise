cards.json: cards-dc.json
	node clean.js > cards.json

cards-dc.json:
	wget https://raw.githubusercontent.com/rezwits/cardnum/master/fdata/cards-dc.json -O cards-dc.json
