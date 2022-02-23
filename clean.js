'use strict'

const cards = require('./cards-dc.json')

const SET_TO_NAME = {
  "METW": "Wizards",
  "METD": "Dragons",
  "MEDM": "DarkMinions",
  "MELE": "LidlessEye",
  "MEWH": "WhiteHand",
  "MEBA": "Balrog",
  "MEAS": "AgainstShadow",
}

console.log(JSON.stringify(
  cards
    .filter(c => c.released === true)
    .filter(c => ["MEAS", "MEBA", "MEDM", "METW", "METD", "MEWH", "MELE"].includes(c.Set))
    .filter(c => c.Primary !== "Region")
    // .sort((a, b) => {
    //   const aTitle = a.normalizedtitle.replace(/"/g, '')
    //   const bTitle = b.normalizedtitle.replace(/"/g, '')
    //   if (aTitle < bTitle) {
    //     return -1
    //   } else if (aTitle > bTitle) {
    //     return 1
    //   }
    //   return 0
    // })
    .map(c => {
      switch (c.DCpath) {
        case "Wizards/SlayerDC.jpg":
          c.DCpath = "Wizards/Slayer.jpg"
          break
      }

      // for better quote searching
      c.Text = c.Text.replace('  Standard Modifications', ' Standard Modifications')

      return c
    })
))
