
# Name That Pokemon!

The Old Script is Dead, Long Live the Extension.

Name That Pokemon is a Gen 3 specific extension for the [Ironmon Tracker](https://github.com/besteon/Ironmon-Tracker) that will allow you to add names using functionality built into the Ironmon Tracker's streamer.bot integration.

## How to Use

1. **Streamer.bot Stream Connect**  
   The extension is designed to work in conjunction with the existing Stream Connect functionality. You can find guidelines on how to set that up here in the [Stream Connect Setup Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Stream-Connect-Guide).

2. **Drop in the Extension**  
   After downloading the latest release ZIP, unzip the contents into your Ironmon Tracker `extensions` folder. You’ll find a Lua script and a folder with the JSON files. It'll give you the script and the directory for the json files. The structure will look like this:

<pre lang="markdown"><code> 
extensions/
├── NameThatPokemon.lua
└── nameThatPokemon/
    ├── namesList.json
    └── ntpVars.json
 </code></pre>

3. **Enable the Command and/or Reward**  
   In the tracker’s **Streaming settings** (figure a), under the **Stream Connect** options (figure b), enable the `!namethatpokemon` command labeled `[EXT] Add a Name for a Pokemon` (figure c) and/or the **Name That Pokemon** channel point reward (figure d). The reward needs one assigned to it from this menu.

     fig a) ![baNxP3k](https://github.com/user-attachments/assets/8cee68fd-a424-4a5a-b1d3-9e33a3510194)

     fig b) ![5YVpC1c](https://github.com/user-attachments/assets/2af91438-1204-44d4-af9c-b35d712cac7a) 
 
     fig c) ![FxTnh8O](https://github.com/user-attachments/assets/eba9de45-31eb-4b5a-9c4c-1338dedf7824)

     fig d) ![RSOJIBG](https://github.com/user-attachments/assets/973346b7-20ba-4e8d-bb2a-40bbcbcee37f)


4. **The Script Works in the Background**  
   Once enabled:
   - Names submitted through chat (!namethatpokemon gleepglorp) or rewards get saved to `namesList.json` (including the submitter's name).
   - Names must be 10 characters, but names past 10 characters will be truncated.
   - The extension watches for when a new run starts (based on game seed) and when a new lead Pokémon appears.
   - If enabling on an existing run, the next name will be injected immediately if it exists.
   - When a valid Pokémon appears in slot 1, the extension injects the next name from the list and logs it as "in use" for that seed.
   - If you pivot mid-run, the same name will be reused until the run resets.

## Guts / Behind the Scenes

The names are truncated to 10 characters because that is the limit in Gen 3. The names are recorded to a namesList.json file that also records the person who requested the name. If you want to do something with the requester like write it to a temporary text file for displaying on an overlay, you can do that but I won't tell you how (unless you sub to [twitch.tv/ratcityretro](twitch.tv/ratcityretro) #streambig).

  

The script monitors the seed changing, the lead pokemon existence, and keeps track of the name in use. Swapping out a new mon from a pivot at any point will inject the same name that is tracked per seed.

  

**SAFARI WARNING: Naming mons placeholder names like BANK will be overwritten by this extension.**

  

## ratcitUNREALTHEFT

Huge shoutout to [UTDZac](https://www.twitch.tv/UTDZac) who made [DeathQuotes](https://github.com/UTDZac/DeathQuotes-IronmonExtension/releases/latest) while I was memeing about it in my channel which gave me the framework to update my script to work as an extension. And [WaffleSmacker](https://www.twitch.tv/WaffleSmacker)'s efforts in exposing the tracker's API for different event use cases. 

  

## Future
This currently only works for USA Gen 3 (probably). I'd love to add in some options:

- Persist the name list
- Shuffle the name list
- Channel point redemption to put the name at the top

## Support
Open an issue here but also just stop by my channel or Discord and it'll probably be an easy solve. 
