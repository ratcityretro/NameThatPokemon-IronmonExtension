--  ▐ ▄  ▄▄▄· • ▌ ▄ ·. ▄▄▄ .    ▄▄▄▄▄ ▄ .▄ ▄▄▄· ▄▄▄▄▄     ▄▄▄·      ▄ •▄ ▄▄▄ .• ▌ ▄ ·.        ▐ ▄ 
-- •█▌▐█▐█ ▀█ ·██ ▐███▪▀▄.▀·    •██  ██▪▐█▐█ ▀█ •██      ▐█ ▄█▪     █▌▄▌▪▀▄.▀··██ ▐███▪▪     •█▌▐█
-- ▐█▐▐▌▄█▀▀█ ▐█ ▌▐▌▐█·▐▀▀▪▄     ▐█.▪██▀▐█▄█▀▀█  ▐█.▪     ██▀· ▄█▀▄ ▐▀▀▄·▐▀▀▪▄▐█ ▌▐▌▐█· ▄█▀▄ ▐█▐▐▌
-- ██▐█▌▐█ ▪▐▌██ ██▌▐█▌▐█▄▄▌     ▐█▌·██▌▐▀▐█ ▪▐▌ ▐█▌·    ▐█▪·•▐█▌.▐▌▐█.█▌▐█▄▄▌██ ██▌▐█▌▐█▌.▐▌██▐█▌
-- ▀▀ █▪ ▀  ▀ ▀▀  █▪▀▀▀ ▀▀▀      ▀▀▀ ▀▀▀ · ▀  ▀  ▀▀▀     .▀    ▀█▄▀▪·▀  ▀ ▀▀▀ ▀▀  █▪▀▀▀ ▀█▄▀▪▀▀ █▪

-- This is based on research and efforts from the PokeHack Community as well as the IronMON Tracker Development team
-- The materials I was able to use for this project was cut down significantly because of them!
-- Requirements: 
-- BizHawk's EmuHawk
-- This script
-- US Version of Pokemon FRLG - WE NEED TO ADD A CHECK TO MAKE SURE THIS GAME IS LOADED
-- A text file full of names
-- Following or subscribing to twitch.tv/ratcityretro
-- Optional:
-- A bot capable of appending a text file locally
-- 
-- Feature requests: capture the username in addition to the name so we can display the name in OBS of the current "namer"
-- Turn this into an extension of the tracker so that we can utilize things like "stillInLab" map data, "is game loaded" boolean, and memory addresses for non-US games


-- Define the mapping of characters to memory values, credit to the Tracker & PokeHack
local characterToMemory = {
    [' '] = 0x00,
    ['À'] = 0x01,
    ['Á'] = 0x02,
    ['Â'] = 0x03,
    ['Ç'] = 0x04,
    ['È'] = 0x05,
    ['É'] = 0x06,
    ['Ê'] = 0x07,
    ['Ë'] = 0x08,
    ['Ì'] = 0x09,
    ['Î'] = 0x0B,
    ['Ï'] = 0x0C,
    ['Ò'] = 0x0D,
    ['Ó'] = 0x0E,
    ['Ô'] = 0x0F,
    ['Œ'] = 0x10,
    ['Ù'] = 0x11,
    ['Ú'] = 0x12,
    ['Û'] = 0x13,
    ['Ñ'] = 0x14,
    ['ß'] = 0x15,
    ['à'] = 0x16,
    ['á'] = 0x17,
    ['ç'] = 0x19,
    ['è'] = 0x1A,
    ['é'] = 0x1B,
    ['ê'] = 0x1C,
    ['ë'] = 0x1D,
    ['ì'] = 0x1E,
    ['î'] = 0x20,
    ['ï'] = 0x21,
    ['ò'] = 0x22,
    ['ó'] = 0x23,
    ['ô'] = 0x24,
    ['œ'] = 0x25,
    ['ù'] = 0x26,
    ['ú'] = 0x27,
    ['û'] = 0x28,
    ['ñ'] = 0x29,
    ['º'] = 0x2A,
    ['ª'] = 0x2B,
    ['&'] = 0x2D,
    ['+'] = 0x2E,
    ['LV'] = 0x34,
    ['='] = 0x35,
    [';'] = 0x36,
    ['¿'] = 0x51,
    ['¡'] = 0x52,
    ['PK'] = 0x53,
    ['MN'] = 0x54,
    ['PO'] = 0x55,
    ['KE'] = 0x56,
    ['BL'] = 0x57,
    ['OC'] = 0x58,
    ['K'] = 0x59,
    ['Í'] = 0x5A,
    ['%'] = 0x5B,
    ['('] = 0x5C,
    [')'] = 0x5D,
    ['â'] = 0x68,
    ['í'] = 0x6F,
    ['UP_ARROW'] = 0x79,
    ['DOWN_ARROW'] = 0x7A,
    ['LEFT_ARROW'] = 0x7B,
    ['RIGHT_ARROW'] = 0x7C,
    ['SUPER_E'] = 0x84,
    ['<'] = 0x85,
    ['>'] = 0x86,
    ['SUPER_RE'] = 0xA0,
    ['0'] = 0xA1,
    ['1'] = 0xA2,
    ['2'] = 0xA3,
    ['3'] = 0xA4,
    ['4'] = 0xA5,
    ['5'] = 0xA6,
    ['6'] = 0xA7,
    ['7'] = 0xA8,
    ['8'] = 0xA9,
    ['9'] = 0xAA,
    ['!'] = 0xAB,
    ['?'] = 0xAC,
    ['.'] = 0xAD,
    ['-'] = 0xAE,
    ['…'] = 0xB0,
    ['“'] = 0xB1,
    ['”'] = 0xB2,
    ['‘'] = 0xB3,
    ["'"] = 0xB4,
    ['♂'] = 0xB5,
    ['♀'] = 0xB6,
    ['¥'] = 0xB7,
    [','] = 0xB8,
    ['×'] = 0xB9,
    ['/'] = 0xBA,
    ['A'] = 0xBB,
    ['B'] = 0xBC,
    ['C'] = 0xBD,
    ['D'] = 0xBE,
    ['E'] = 0xBF,
    ['F'] = 0xC0,
    ['G'] = 0xC1,
    ['H'] = 0xC2,
    ['I'] = 0xC3,
    ['J'] = 0xC4,
    ['K'] = 0xC5,
    ['L'] = 0xC6,
    ['M'] = 0xC7,
    ['N'] = 0xC8,
    ['O'] = 0xC9,
    ['P'] = 0xCA,
    ['Q'] = 0xCB,
    ['R'] = 0xCC,
    ['S'] = 0xCD,
    ['T'] = 0xCE,
    ['U'] = 0xCF,
    ['V'] = 0xD0,
    ['W'] = 0xD1,
    ['X'] = 0xD2,
    ['Y'] = 0xD3,
    ['Z'] = 0xD4,
    ['a'] = 0xD5,
    ['b'] = 0xD6,
    ['c'] = 0xD7,
    ['d'] = 0xD8,
    ['e'] = 0xD9,
    ['f'] = 0xDA,
    ['g'] = 0xDB,
    ['h'] = 0xDC,
    ['i'] = 0xDD,
    ['j'] = 0xDE,
    ['k'] = 0xDF,
    ['l'] = 0xE0,
    ['m'] = 0xE1,
    ['n'] = 0xE2,
    ['o'] = 0xE3,
    ['p'] = 0xE4,
    ['q'] = 0xE5,
    ['r'] = 0xE6,
    ['s'] = 0xE7,
    ['t'] = 0xE8,
    ['u'] = 0xE9,
    ['v'] = 0xEA,
    ['w'] = 0xEB,
    ['x'] = 0xEC,
    ['y'] = 0xED,
    ['z'] = 0xEE,
    ['?'] = 0xEF,
    [':'] = 0xF0,
    ['Ä'] = 0xF1,
    ['Ö'] = 0xF2,
    ['Ü'] = 0xF3,
    ['ä'] = 0xF4,
    ['ö'] = 0xF5,
    ['ü'] = 0xF6,
    ['$'] = 0xFF,
}

-- Constants for startAddress for US version of FRLG, memory offset for pokémon nicknames, and path to filename
local START_ADDRESS = 0x02024284
local OFFSET = 8
-- Change either to whatever hard path you want to use
local FILENAME = "names.txt" 
local TEMP_FILENAME = "names_temp.txt"

-- Primary function to convert and write a name to memory addresses from the names file
local function convertAndWriteToMemory()
    -- Set memory domain (this is a "just in case" the user is running other scripts changing the domain, will remove when this becomes an extension)
    memory.usememorydomain("System Bus")
    
    -- Attempt to open the input file
    local inputFile = io.open(FILENAME, "r")

    if not inputFile then
        print("Error: Unable to open name file.")
        return
    end

    local name = inputFile:read()

  -- Ensure the name is no longer than 10 characters
  if name == nil then
    print("Error: Name file is empty.")
    inputFile:close()
    return
    elseif #name > 10 then
    -- Trim to 10 characters if longer
    name = name:sub(1, 10)
    elseif #name < 10 then
    -- Calculate how many bytes are needed for padding
    local paddingLength = 10 - #name
    -- Pad with 0xFF followed by 0x00 bytes
    -- Pokémon nicknames always end with 0xFF and then empty bytes
    name = name .. string.char(0xFF) .. string.rep(string.char(0x00), paddingLength - 1)
    end
    
    local address = START_ADDRESS + OFFSET

    -- Attempt to write to memory
    for i = 1, #name do
        local char = name:sub(i, i)
        local memoryValue = characterToMemory[char] or 0xFF  -- Default the character to 0xFF if character not found

        local success = memory.writebyte(address,memoryValue)
        
        local reader = memory.readbyte(address)

        if reader ~= memoryValue then
            print("Error: Failed to write to memory.")
            inputFile:close()
            return
        end

        -- Increment the address by 1 for each byte
        address = address + 1
    end

    -- Attempt to write to the temp file
    -- This is because I'm bad at Lua and everything happens so fast so we need a temp file that has the remaining names
    -- This creates a race condition where a name comes in right as you are getting a new mon
    local newInputFile = assert(io.open(TEMP_FILENAME, "w"))

    if not newInputFile then
        print("Error: Unable to open input file for writing.")
        return
    end

    for line in inputFile:lines() do
        if line ~= name then
            local success = newInputFile:write(line .. "\n")
            if not success then
                print("Error: Failed to write to output file.")
                newInputFile:close()
                return
            end
        end
    end
    inputFile:close()
    newInputFile:close()
    print("The name has been recorded to the pokemon.")
    os.remove(FILENAME)
    os.rename(TEMP_FILENAME,FILENAME)
    reRun()
end

function Run(reRunMode)
    local loopRun = true
    while loopRun do
        local memCheck = memory.readbyte(START_ADDRESS)
        emu.frameadvance()
        if (reRunMode and memCheck == 0) or (not reRunMode and memCheck > 0) then
            loopRun = false
            convertAndWriteToMemory()
        end
    end
    -- Final garbage collection prior to loops beginning, might be unnecessary but loops scare me
    collectgarbage()
end

-- Initial run
Run(false)
-- Re-run
Run(true)

