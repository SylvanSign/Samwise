# Samwise
MECCG Card Gallery &amp; Deckbuilder

![screenshot](https://user-images.githubusercontent.com/18179992/155857321-aa5e0913-bb10-45e8-9468-303b8769538b.png)

Features:
- MtG: Arena inspired card gallery + deck builder
- basic card filtering (to be expanded in the future...)
- fast and totally offline after initial setup
- support for all standard cards (no DC yet, but maybe someday, if there's interest!)
- save/load decks locally using human-readable plaintext files
  - pre-loaded with the 10 Challenge Deck lists
- import/export decks using the decklist format from cardnum.net
- different zoom levels for card grid/gallery

This is [Free (_as in Freedom_) Software](https://www.gnu.org/philosophy/free-sw.en.html) using the [AGPLv3 License](./LICENSE.md#gnu-affero-general-public-license), and pre-compiled downloads can be found on [the Releases page](https://github.com/SylvanSign/samwise/releases).

Built using Godot, which is an amazing and Free (_as in Freedom_) Software Game Engine!
- Site https://godotengine.org/
- License https://godotengine.org/license

Card metadata sourced from [cardnum](https://github.com/rezwits/cardnum):
- https://github.com/rezwits/cardnum/blob/master/fdata/cards-dc.json

This repo contains no card assets, but those may be sourced from elsewhere on first run. This requires [`git` to be installed](https://github.com/git-guides/install-git#install-git). See [PckDownloader.gd](./scenes/PckDownloader.gd) for details.
