- [x] fix drop onto section card
- [x] fix match issue related to empty string (eg. "Black Horse" not found in
      search)
- [x] switch to download & build pck of cards
- [ ] handle different grid "zoom levels" to go from single card up to something like 8x5
  - [ ] maybe also allow collapsing of deck builder for a standalone gallery mode
    - [ ] collapsed by default
    - [ ] preview and drag and decklist interaction disabled in this mode?
- [ ] fix section card preview glitching between cards
  - probably want to make it so each card doesn't trigger its own preview, but
    the deck section and other parents handle ending preview _wildcard_match
