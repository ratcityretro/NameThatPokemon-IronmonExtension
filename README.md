
# Name That Pokemon!

The Old Script is Dead, Long Live the Extension.

  

Name That Pokemon is a Gen 3 specific extension for the [Ironmon Tracker](https://github.com/besteon/Ironmon-Tracker) that will allow you to add names using functionality built into the Ironmon Tracker's streamer.bot integration.

  

## Setup

I zipped up the goods, so download the zip file from the latest release and unzip it to your extensions folder. It'll give you the script and the directory for the json files.

  

Enable the !namethatpokemon command (or rename it from that) and/or enable the Name That Pokemon reward from the Streaming settings menu in the tracker. Names added from either method will be at the bottom of the list.

  

## Guts

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
