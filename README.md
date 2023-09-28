# Name That Pokemon!
A script that can be loaded into BizHawk's EmuHawk Lua console that will automatically inject names from a list within a text file. 

## Setup
This is jank so bear with me:

Download the script to your Lua folder for BizHawk

Create a names.txt file in the same location

Setup your Streamerbot with an action that will take the chatter's name and append the names.txt file

---Import this and it'll do that for you: https://pastebin.com/rx5HRLfB

!ntp will record the name to the file. Sometimes blank lines will append in, but the script will clear those

All cool scripts have warnings: 

The script loads a name when you go from ZERO POKEMON to ONE POKEMON. So loading up a savestate with a pokemon to continue your run mimics this "acquisition" - this can be worked around by leaving the emulator open between streams like a real gamer 

## Proof of Concept
This is a POC to write nicknames to the 10 bytes available within the memory of a pokemon game. This started out as an idea that I threw at an AI because I did not know any Lua, so through some refinement we got it to this point. Streamerbot will only need to append to a textfile (names.txt by default) the chatter's input.

## Future
This will become an extension for the ironmon tracker eventually. We need to take advantage of resources within the tracker for the following:
- Location detection so this only runs in the lab
- Reload detection so it doesn't overwrite a name when a user continues a run

Other features planned:
- Randomizing as an option to select the name, which will need a UI
- Channel point redemption to gate the command or allow for line jumping the queue, also needs a UI
- Logging usernames and delimiting them so they can be included in an OBS overlay to show the current "namer"