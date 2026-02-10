local function NameThatPokemon()
    local self = {}
    self.version = "1.3"
    self.name = "Name That Pokemon"
    self.author = "ratcityretro"
    self.description =
        "Using a command or a channel point redemption, your chat can add names to the queue that will automatically inject per seed."
    self.github = "ratcityretro/NameThatPokemon-IronmonExtension"
    self.url = string.format("https://github.com/%s", self.github or "")

    local namesFilename = "NameThatPokemon/namesList.json"
    local stateFilename = "NameThatPokemon/ntpVars.json"
    local namerFilename = "NameThatPokemon/namer.txt"
    -- Run fingerprint = game + seed, scoped per profile so profile switch doesn't overwrite
    local previousRunFingerprint = nil
    -- So we only write namer.txt when profile or currentNamer changed (single file for OBS)
    local lastWrittenProfileKey = nil
    local lastWrittenNamer = nil
    local newLine = "\r\n"

    -- uniqueId = game + currentSeed (per profile). TID alone is often same across new seeds; seed changes per run.
    local function getRunFingerprint()
        local seed = Main.currentSeed
        if seed == nil then return nil end
        return tostring(GameSettings.game) .. "_" .. tostring(seed)
    end

    local function getProfileKey()
        local id = Options["Active Profile"]
        return (id ~= nil and id ~= "") and id or "default"
    end

    self.DefaultNames = {}

    -- Single file keyed by profileId; returns state for current profile only { uniqueId, currentName }
    local function readNtpVars()
        local filepath = self.getFilepathForState()
        if not FileManager.fileExists(filepath) then return {} end
        local full = FileManager.decodeJsonFile(filepath) or {}
        local key = getProfileKey()
        return full[key] or {}
    end

    function self.getFilepathForNames()
        return FileManager.getCustomFolderPath() .. namesFilename
    end

    function self.getNamesFromFile()
        local filepath = self.getFilepathForNames()
        if not filepath then return {} end
        return FileManager.decodeJsonFile(filepath) or {}
    end

    function self.saveNamesToFile(names)
        local filepath = self.getFilepathForNames()
        if not filepath then return end
        FileManager.encodeToJsonFile(filepath, names or {})
    end

function self.getNamerFilePath()
    return FileManager.getCustomFolderPath() .. namerFilename
end

function self.updateNamerTextFile(namer)
    local folder = FileManager.getCustomFolderPath() .. "NameThatPokemon"
    if not FileManager.fileExists(folder) then
        -- bizhawk might not have mkdir, so fallback to os.execute
        os.execute(('mkdir "%s"'):format(folder))
    end

    local path = self.getNamerFilePath()
    local f = io.open(path, "w")
    if not f then
        print("NameThatPokemon: could not write namer.txt to", path)
        return
    end
    f:write(namer or "")
    f:close()
end
    

    -- ntpVars.json: single file, keyed by profileId; currentNamer = who submitted the name (for namer.txt sync)
    -- { "<profileId>": { "uniqueId": "3_123456", "currentName": "Pikachu", "currentNamer": "Puffsun" }, ... }

    function self.getFilepathForState()
        return FileManager.getCustomFolderPath() .. stateFilename
    end

    function self.saveCurrentNameState(uniqueIdparam, currentName, currentNamer)
        local filepath = self.getFilepathForState()
        if not filepath then return end

        local full = FileManager.decodeJsonFile(filepath) or {}
        local key = getProfileKey()
        full[key] = full[key] or {}
        full[key].uniqueId = uniqueIdparam or full[key].uniqueId or ""
        full[key].currentName = currentName or full[key].currentName or ""
        full[key].currentNamer = currentNamer or full[key].currentNamer or ""

        FileManager.encodeToJsonFile(filepath, full)
    end

    local function truncateTo10(input)
        local truncated = ""
        local count = 0
        for _, code in utf8.codes(input) do
            if count < 10 then
                truncated = truncated .. utf8.char(code)
                count = count + 1
            else
                break
            end
        end
        return truncated
    end

    -- True when current seed (for this profile) differs from persisted uniqueId for this profile
    local function hasRunChanged()
        local fp = getRunFingerprint()
        if not fp then return false end
        local saved = readNtpVars()
        if (saved.uniqueId or "") ~= fp then
            previousRunFingerprint = fp
            return true
        end
        previousRunFingerprint = fp
        return false
    end

    local characterToMemory = {
        [' '] = 0x00,
        ['_'] = 0x00,
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
        ['$'] = 0xFF
    }

    local function mapUTF8StringAndOutput(inputString)
        local mapped = {}
        for _, char in utf8.codes(inputString) do
            local val = characterToMemory[utf8.char(char)] or 0xFF
            table.insert(mapped, val)
        end
        if #mapped > 10 then mapped = {table.unpack(mapped, 1, 10)} end
        while #mapped < 10 do table.insert(mapped, 0xFF) end
        return mapped
    end

    -- Game checks to determine address nonsense, 3 = FRLG, 2 = Emerald
    local function isPlayingFRLG() return GameSettings.game == 3 end
    local function isPlayingE() return GameSettings.game == 2 end
    -- Waffle had this check idk I might use it later
    local function isPlayingFRorE() return isPlayingFRLG() or isPlayingE() end

    -- namer: optional; when provided (e.g. from queue entry), save to state and write namer.txt
    local function injectName(name, namer)
        memory.usememorydomain("System Bus")
        Resources.namesList = Resources.namesList or {}
        if #Resources.namesList == 0 then return end
    
        local entry = Resources.namesList[1]
        if not entry or not entry.name then return end
    
        -- write the name into game memory
        local mapped = mapUTF8StringAndOutput(name)
        local address = isPlayingFRLG() and 0x0202428C
                     or isPlayingE()   and 0x020244EC
                     or nil
        if not address then return end
        for _, byte in ipairs(mapped) do
            memory.writebyte(address, byte)
            address = address + 1
        end
    
        -- save state (namer = who submitted, so we can sync namer.txt when switching profile)
        self.saveCurrentNameState(nil, truncateTo10(name), namer)
    
        if namer then
            self.updateNamerTextFile(namer)
            lastWrittenProfileKey = getProfileKey()
            lastWrittenNamer = namer
        end
    
        -- remove *one* time from the queue and save
        table.remove(Resources.namesList, 1)
        self.saveNamesToFile(Resources.namesList)
    end
    

    function self.afterProgramDataUpdate()
        if not isPlayingFRLG() or not Program.isValidMapLocation() then
            return
        end

        Resources.namesList = Resources.namesList or {}
        local leadPokemon = Tracker.getPokemon(1, true)
        local ntpVars = readNtpVars()

        -- Reset when a new seed is detected (per profile; state file is profile-specific)
        if hasRunChanged() then
            self.saveCurrentNameState(previousRunFingerprint, "", "")
            nameBurned = false
            return
        end

        -- Sync namer.txt to current profile's namer when profile or namer changed (single file for OBS)
        local profileKey = getProfileKey()
        local currentNamer = ntpVars.currentNamer or ""
        if profileKey ~= lastWrittenProfileKey or currentNamer ~= lastWrittenNamer then
            self.updateNamerTextFile(currentNamer)
            lastWrittenProfileKey = profileKey
            lastWrittenNamer = currentNamer
        end

        -- Wait until a valid lead Pokémon exists
        if not leadPokemon or not PokemonData.isValid(leadPokemon.pokemonID) then
            return
        end

        -- Inject name once per seed (pass namer so state + namer.txt get it)
        if leadPokemon.nickname and not nameBurned then
            local entry = Resources.namesList[1]
            if entry and entry.name then
                injectName(entry.name, entry.namer)
                nameBurned = true
            end
            return
        end

        -- Re-inject saved name if lead Pokémon name has changed (no namer param; state keeps currentNamer)
        if ntpVars.currentName and leadPokemon.nickname ~= ntpVars.currentName then
            if ntpVars.currentName and ntpVars.currentName ~= "" then
                injectName(ntpVars.currentName)
            end
        end
    end

    function self.tryAddName(event, request)
        local response = {AdditionalInfo = {AutoComplete = false}}
        local inputName = request.SanitizedInput

        if not inputName or inputName == "" then
            response.Message = string.format(
                                   "> %s, please enter a name (up to 10 characters).",
                                   request.Username)
            return response
        end

        local truncated = truncateTo10(inputName)
        local newEntry = {name = inputName, namer = request.Username}

        Resources.namesList = Resources.namesList or {}
        table.insert(Resources.namesList, newEntry)
        self.saveNamesToFile(Resources.namesList)

        response.Message = string.format("> %s added the name '%s' to the list!",
                                         request.Username, truncated)
        response.AdditionalInfo.AutoComplete = event.O_AutoComplete or false
        return response
    end

    self.RewardEvent = EventHandler.IEvent:new({
        Key = "CR_NameThatPokemonAdd",
        Type = EventHandler.EventTypes.Reward,
        Name = "[EXT] Add a Name for Pokémon",
        RewardId = "", --this gets filled in by the tracker later when you select it
        Options = {"O_SendMessage", "O_AutoComplete"},
        O_SendMessage = true,
        O_AutoComplete = true,
        Fulfill = function(this, request)
            return self.tryAddName(this, request)
        end
    })
    self.RewardEvent.IsEnabled = false

    self.CommandEvent = EventHandler.IEvent:new({
        Key = "CMD_NameThatPokemonAdd",
        Type = EventHandler.EventTypes.Command,
        Name = "[EXT] Add a Name for Pokémon",
        Command = "!namethatpokemon",
        Help = "> Adds a name (up to 10 characters) to the Name-That-Pokémon list.",
        Fulfill = function(this, request)
            local response = self.tryAddName(this, request)
            response.AdditionalInfo = nil
            return response
        end
    })
    self.CommandEvent.IsEnabled = false

    function self.tryGetNameCount(event, request)
        local names = self.getNamesFromFile()
        local count = (names and #names) or 0
        return {
            Message = string.format("> There are %d name(s) in the list.", count)
        }
    end

    self.CommandEventNameCount = EventHandler.IEvent:new({
        Key = "CMD_NameThatPokemonNameCount",
        Type = EventHandler.EventTypes.Command,
        Name = "[EXT] Get the name count",
        Command = "!namecount",
        Help = "> Returns the number of entries in the names list.",
        Fulfill = function(this, request)
            return self.tryGetNameCount(this, request)
        end
    })
    self.CommandEventNameCount.IsEnabled = false

    function self.openPopup()
        local x, y, w, h, lineHeight = 20, 15, 600, 405, 20
        local bottomPadding = 115
        local form = Utils.createBizhawkForm("Edit Names List", w, h, 80, 20)

        forms.label(form,
                    "Edit existing names or add new ones (format: Name - Namer), one per line:",
                    x, y, w - 40, lineHeight)
        y = y + 20

        local lines = {}
        for _, entry in ipairs(Resources.namesList or {}) do
            table.insert(lines,
                         (entry.name or "") .. " - " .. (entry.namer or ""))
        end

        local namesAsText = table.concat(lines, newLine)
        local namesTextBox = forms.textbox(form, namesAsText, w - 40,
                                           h - bottomPadding, nil, x - 1, y,
                                           true, true, "Vertical")
        y = y + (h - bottomPadding) + 10

        forms.button(form, Resources.AllScreens.Save, function()
            local text = forms.gettext(namesTextBox) or ""
            local newNames = {}
            for line in string.gmatch(text, "[^\r\n]+") do
                local namePart, namerPart = line:match("^(.-)%s*%-%s*(.*)$")
                if namePart then
                    table.insert(newNames, {name = namePart, namer = namerPart})
                elseif line ~= "" then
                    table.insert(newNames, {name = line, namer = ""})
                end
            end
            Resources.namesList = newNames
            self.saveNamesToFile(newNames)
            Utils.closeBizhawkForm(form)
        end, x + 115, y)

        forms.button(form, "(Default)", function()
            if self.DefaultNames and #self.DefaultNames > 0 then
                local defaultLines = {}
                for _, entry in ipairs(self.DefaultNames) do
                    table.insert(defaultLines,
                                 entry.name .. " - " .. entry.namer)
                end
                forms.settext(namesTextBox, table.concat(defaultLines, newLine))
            end
        end, x + 225, y)

        forms.button(form, Resources.AllScreens.Cancel,
                     function() Utils.closeBizhawkForm(form) end, x + 335, y)
    end

    function self.configureOptions() self.openPopup() end

    function self.startup()
        self.DefaultNames = {}
        Resources.namesList = {}

        -- Sync run fingerprint so we don't false-trigger on first frame
        previousRunFingerprint = getRunFingerprint() or readNtpVars().uniqueId

        local filepath = self.getFilepathForNames()
        if FileManager.fileExists(filepath) then
            local names = self.getNamesFromFile()
            if names and #names > 0 then
                FileManager.copyTable(names, Resources.namesList)
            end
        else
            self.saveNamesToFile(Resources.namesList)
        end

        FileManager.copyTable(Resources.namesList, self.DefaultNames)

        EventHandler.addNewEvent(self.RewardEvent)
        EventHandler.addNewEvent(self.CommandEvent)
        EventHandler.addNewEvent(self.CommandEventNameCount)
    end

    function self.unload()
        if self.DefaultNames and #self.DefaultNames > 0 then
            Resources.namesList = {}
            FileManager.copyTable(self.DefaultNames, Resources.namesList)
        end

        EventHandler.removeEvent(self.RewardEvent.Key)
        EventHandler.removeEvent(self.CommandEvent.Key)
        EventHandler.removeEvent(self.CommandEventNameCount.Key)
    end

    function self.checkForUpdates()
        local versionCheckUrl = string.format(
                                    "https://api.github.com/repos/%s/releases/latest",
                                    self.github)
        local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"'
        local downloadUrl = string.format(
                                "https://github.com/%s/releases/latest",
                                self.github)
        local compareFunc = function(a, b)
            return a ~= b and not Utils.isNewerVersion(a, b)
        end
        local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl,
                                                              self.version,
                                                              versionResponsePattern,
                                                              compareFunc)
        return isUpdateAvailable, downloadUrl
    end

    function self.downloadAndInstallUpdate()
        local extensionFilenameKey = "NameThatPokemon"
        return TrackerAPI.updateExtension(extensionFilenameKey)
    end

    return self
end

return NameThatPokemon

