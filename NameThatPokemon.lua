local function NameThatPokemon()
    local self = {}
    self.version = "0.6"
    self.name = "Name That Pokemon"
    self.author = "ratcityretro"
    self.description = "Reads a JSON names list, converts the first entry’s name to in-game memory, and integrates chat commands and reward events."
    self.github = "ratcityretro/name-that-pokemon"
    self.url = string.format("https://github.com/%s", self.github or "")

    local NAMES_FILENAME = "NamesList.json"
    local NEWLINE = "\r\n"
    self.DefaultNames = {}

    function self.getFilepathForNames()
        return FileManager.getCustomFolderPath() .. NAMES_FILENAME
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

    local characterToMemory = {
        [' '] = 0x00, ['_'] = 0x00,
        ['À'] = 0x01, ['Á'] = 0x02, ['Â'] = 0x03, ['Ç'] = 0x04,
        ['È'] = 0x05, ['É'] = 0x06, ['Ê'] = 0x07, ['Ë'] = 0x08,
        ['Ì'] = 0x09, ['Î'] = 0x0B, ['Ï'] = 0x0C, ['Ò'] = 0x0D,
        ['Ó'] = 0x0E, ['Ô'] = 0x0F, ['Œ'] = 0x10, ['Ù'] = 0x11,
        ['Ú'] = 0x12, ['Û'] = 0x13, ['Ñ'] = 0x14, ['ß'] = 0x15,
        ['à'] = 0x16, ['á'] = 0x17, ['ç'] = 0x19, ['è'] = 0x1A,
        ['é'] = 0x1B, ['ê'] = 0x1C, ['ë'] = 0x1D, ['ì'] = 0x1E,
        ['î'] = 0x20, ['ï'] = 0x21, ['ò'] = 0x22, ['ó'] = 0x23,
        ['ô'] = 0x24, ['œ'] = 0x25, ['ù'] = 0x26, ['ú'] = 0x27,
        ['û'] = 0x28, ['ñ'] = 0x29, ['º'] = 0x2A, ['ª'] = 0x2B,
        ['&'] = 0x2D, ['+'] = 0x2E, ['LV'] = 0x34, ['='] = 0x35,
        [';'] = 0x36, ['¿'] = 0x51, ['¡'] = 0x52, ['PK'] = 0x53,
        ['MN'] = 0x54, ['PO'] = 0x55, ['KE'] = 0x56, ['BL'] = 0x57,
        ['OC'] = 0x58, ['K'] = 0x59, ['Í'] = 0x5A, ['%'] = 0x5B,
        ['('] = 0x5C, [')'] = 0x5D, ['â'] = 0x68, ['í'] = 0x6F,
        ['UP_ARROW'] = 0x79, ['DOWN_ARROW'] = 0x7A, ['LEFT_ARROW'] = 0x7B,
        ['RIGHT_ARROW'] = 0x7C, ['SUPER_E'] = 0x84, ['<'] = 0x85,
        ['>'] = 0x86, ['SUPER_RE'] = 0xA0, ['0'] = 0xA1, ['1'] = 0xA2,
        ['2'] = 0xA3, ['3'] = 0xA4, ['4'] = 0xA5, ['5'] = 0xA6,
        ['6'] = 0xA7, ['7'] = 0xA8, ['8'] = 0xA9, ['9'] = 0xAA,
        ['!'] = 0xAB, ['?'] = 0xAC, ['.'] = 0xAD, ['-'] = 0xAE,
        ['…'] = 0xB0, ['“'] = 0xB1, ['”'] = 0xB2, ['‘'] = 0xB3,
        ["'"] = 0xB4, ['♂'] = 0xB5, ['♀'] = 0xB6, ['¥'] = 0xB7,
        [','] = 0xB8, ['×'] = 0xB9, ['/'] = 0xBA, ['A'] = 0xBB,
        ['B'] = 0xBC, ['C'] = 0xBD, ['D'] = 0xBE, ['E'] = 0xBF,
        ['F'] = 0xC0, ['G'] = 0xC1, ['H'] = 0xC2, ['I'] = 0xC3,
        ['J'] = 0xC4, ['K'] = 0xC5, ['L'] = 0xC6, ['M'] = 0xC7,
        ['N'] = 0xC8, ['O'] = 0xC9, ['P'] = 0xCA, ['Q'] = 0xCB,
        ['R'] = 0xCC, ['S'] = 0xCD, ['T'] = 0xCE, ['U'] = 0xCF,
        ['V'] = 0xD0, ['W'] = 0xD1, ['X'] = 0xD2, ['Y'] = 0xD3,
        ['Z'] = 0xD4, ['a'] = 0xD5, ['b'] = 0xD6, ['c'] = 0xD7,
        ['d'] = 0xD8, ['e'] = 0xD9, ['f'] = 0xDA, ['g'] = 0xDB,
        ['h'] = 0xDC, ['i'] = 0xDD, ['j'] = 0xDE, ['k'] = 0xDF,
        ['l'] = 0xE0, ['m'] = 0xE1, ['n'] = 0xE2, ['o'] = 0xE3,
        ['p'] = 0xE4, ['q'] = 0xE5, ['r'] = 0xE6, ['s'] = 0xE7,
        ['t'] = 0xE8, ['u'] = 0xE9, ['v'] = 0xEA, ['w'] = 0xEB,
        ['x'] = 0xEC, ['y'] = 0xED, ['z'] = 0xEE, ['?'] = 0xEF,
        [':'] = 0xF0, ['Ä'] = 0xF1, ['Ö'] = 0xF2, ['Ü'] = 0xF3,
        ['ä'] = 0xF4, ['ö'] = 0xF5, ['ü'] = 0xF6, ['$'] = 0xFF,
    }

    local function mapUTF8StringAndOutput(inputString)
        local mapped = {}
        for _, char in utf8.codes(inputString) do
            local val = characterToMemory[utf8.char(char)] or 0xFF
            table.insert(mapped, val)
        end
        if #mapped > 10 then
            mapped = {table.unpack(mapped, 1, 10)}
        end
        while #mapped < 10 do
            table.insert(mapped, 0xFF)
        end
        return mapped
    end

    local function injectName()
        memory.usememorydomain("System Bus")
        Resources.NamesList = Resources.NamesList or {}
        if #Resources.NamesList == 0 then return end

        local entry = Resources.NamesList[1]
        if not entry or not entry.name then return end

        local name = entry.name
        local mappedName = mapUTF8StringAndOutput(name)
        local address = 0x0202428C -- FRLG nickname memory address

        for _, byte in ipairs(mappedName) do
            memory.writebyte(address, byte)
            address = address + 1
        end

        print("Injected name: '" .. truncateTo10(name) .. "' into game memory.")
        table.remove(Resources.NamesList, 1)
        self.saveNamesToFile(Resources.NamesList)
    end

    local loopRun = true
    local startAddress = 0x02024284

    function self.afterProgramDataUpdate()
        Resources.NamesList = Resources.NamesList or {}
        local memCheck = memory.readbyte(startAddress)
        if memCheck > 0 then
            if loopRun then
                injectName()
                loopRun = false
            end
        elseif memCheck == 0 then
            loopRun = true
        end
    end

    function self.tryAddName(event, request)
        local response = { AdditionalInfo = { AutoComplete = false } }
        local inputName = request.SanitizedInput

        if not inputName or inputName == "" then
            response.Message = string.format("> %s, please enter a name (up to 10 characters).", request.Username)
            return response
        end

        local truncated = truncateTo10(inputName)
        local newEntry = { name = inputName, namer = request.Username }

        Resources.NamesList = Resources.NamesList or {}
        table.insert(Resources.NamesList, newEntry)
        self.saveNamesToFile(Resources.NamesList)

        response.Message = string.format("> %s added name '%s' to the list.", request.Username, truncated)
        response.AdditionalInfo.AutoComplete = event.O_AutoComplete or false
        return response
    end

    self.RewardEvent = EventHandler.IEvent:new({
        Key = "CR_NameThatPokemonAdd",
        Type = EventHandler.EventTypes.Reward,
        Name = "[EXT] Add a Name for Pokémon",
        RewardId = "",
        Options = { "O_SendMessage", "O_AutoComplete" },
        O_SendMessage = true,
        O_AutoComplete = true,
        Fulfill = function(this, request)
            return self.tryAddName(this, request)
        end,
    })
    self.RewardEvent.IsEnabled = false

    self.CommandEvent = EventHandler.IEvent:new({
        Key = "CMD_NameThatPokemonAdd",
        Type = EventHandler.EventTypes.Command,
        Name = "[EXT] Add a Name for Pokémon",
        Command = "!ntp",
        Help = "> Adds a name (up to 10 characters) to the Name-That-Pokémon list.",
        Fulfill = function(this, request)
            local response = self.tryAddName(this, request)
            response.AdditionalInfo = nil
            return response
        end,
    })
    self.CommandEvent.IsEnabled = false

    function self.openPopup()
        local x, y, w, h, lineHeight = 20, 15, 600, 405, 20
        local bottomPadding = 115
        local form = Utils.createBizhawkForm("Edit Names List", w, h, 80, 20)

        forms.label(form, "Edit existing names or add new ones (format: Name - Namer), one per line:", x, y, w - 40, lineHeight)
        y = y + 20

        local lines = {}
        for _, entry in ipairs(Resources.NamesList or {}) do
            table.insert(lines, (entry.name or "") .. " - " .. (entry.namer or ""))
        end

        local namesAsText = table.concat(lines, NEWLINE)
        local namesTextBox = forms.textbox(form, namesAsText, w - 40, h - bottomPadding, nil, x - 1, y, true, true, "Vertical")
        y = y + (h - bottomPadding) + 10

        forms.button(form, Resources.AllScreens.Save, function()
            local text = forms.gettext(namesTextBox) or ""
            local newNames = {}
            for line in string.gmatch(text, "[^\r\n]+") do
                local namePart, namerPart = line:match("^(.-)%s*%-%s*(.*)$")
                if namePart then
                    table.insert(newNames, { name = namePart, namer = namerPart })
                elseif line ~= "" then
                    table.insert(newNames, { name = line, namer = "" })
                end
            end
            Resources.NamesList = newNames
            self.saveNamesToFile(newNames)
            Utils.closeBizhawkForm(form)
        end, x + 115, y)

        forms.button(form, "(Default)", function()
            if self.DefaultNames and #self.DefaultNames > 0 then
                local defaultLines = {}
                for _, entry in ipairs(self.DefaultNames) do
                    table.insert(defaultLines, entry.name .. " - " .. entry.namer)
                end
                forms.settext(namesTextBox, table.concat(defaultLines, NEWLINE))
            end
        end, x + 225, y)

        forms.button(form, Resources.AllScreens.Cancel, function()
            Utils.closeBizhawkForm(form)
        end, x + 335, y)
    end

    function self.configureOptions()
        self.openPopup()
    end

    function self.startup()
        self.DefaultNames = {}
        Resources.NamesList = {}

        local filepath = self.getFilepathForNames()
        if FileManager.fileExists(filepath) then
            local names = self.getNamesFromFile()
            if names and #names > 0 then
                FileManager.copyTable(names, Resources.NamesList)
            end
        else
            self.saveNamesToFile(Resources.NamesList)
        end

        FileManager.copyTable(Resources.NamesList, self.DefaultNames)

        EventHandler.addNewEvent(self.RewardEvent)
        EventHandler.addNewEvent(self.CommandEvent)
    end

    function self.unload()
        if self.DefaultNames and #self.DefaultNames > 0 then
            Resources.NamesList = {}
            FileManager.copyTable(self.DefaultNames, Resources.NamesList)
        end

        EventHandler.removeEvent(self.RewardEvent.Key)
        EventHandler.removeEvent(self.CommandEvent.Key)
    end

    function self.checkForUpdates()
        local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github)
        local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"'
        local downloadUrl = string.format("https://github.com/%s/releases/latest", self.github)
        local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end
        local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
        return isUpdateAvailable, downloadUrl
    end

    function self.downloadAndInstallUpdate()
        local extensionFilenameKey = "NameThatPokemon"
        return TrackerAPI.updateExtension(extensionFilenameKey)
    end

    return self
end

return NameThatPokemon

