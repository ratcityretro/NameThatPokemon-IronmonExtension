local function NameThatPokemon()
    local self = {}
    self.version = "0.5"
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

    local characterToMemory = { -- unchanged table omitted here for brevity }

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

    -- 🧠 Core Injection Function
    local function injectName()
        memory.usememorydomain("System Bus")
        Resources.NamesList = Resources.NamesList or {}

        if #Resources.NamesList == 0 then return end

        local entry = Resources.NamesList[1]
        if not entry or not entry.name then return end

        local name = entry.name
        local mappedName = mapUTF8StringAndOutput(name)
        local address = 0x0202428C  -- Nickname memory location for FRLG (US)

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
        Resources.NamesList = Resources.NamesList or {} -- Safe fallback

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

    -- 🔧 Startup logic
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

    -- 🔄 Update check
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
