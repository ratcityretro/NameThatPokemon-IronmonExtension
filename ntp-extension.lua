local function CodeExtensionTemplate()
    local self = {}
    self.version = "0.2"
    self.name = "Name That Pokemon"
    self.author = "ratcityretro"  -- Change to your username
    self.description = "Reads a JSON names list, converts the first entry’s name to in-game memory, and provides an options dialog for editing."
    self.github = "ratcityretro/name-that-pokemon"  -- Adjust as needed
    self.url = string.format("https://github.com/%s", self.github or "")

    -- NOTE FOR ANYONE CHECKING THIS OUT, this was the first pass on o3-mini-high so the code is going to be unsanded
        --------------------------------------
        -- Internal variables & constants
        --------------------------------------
        local loopRun = true
        local startAddress = 0x02024284  -- Memory address used for checking game state
        local NAMES_FILENAME = "NamesList.json"
        local NEWLINE = "\r\n"
    
        --------------------------------------
        -- JSON File Management Functions
        --------------------------------------
        function self.getFilepathForNames()
            return FileManager.getCustomFolderPath() .. NAMES_FILENAME
        end
    
        function self.getNamesFromFile()
            local filepath = self.getFilepathForNames()
            if not filepath or not FileManager.fileExists(filepath) then
                return {}
            end
            return FileManager.decodeJsonFile(filepath) or {}
        end
    
        function self.saveNamesToFile(names)
            local filepath = self.getFilepathForNames()
            if not filepath then
                return
            end
            FileManager.encodeToJsonFile(filepath, names or {})
        end
    
        --------------------------------------
        -- Character Mapping Table (used to convert names)
        --------------------------------------
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
    
        -- Helper: Convert a UTF-8 string into a table of memory values (max 10 characters, padded with 0xFF)
        local function mapUTF8StringAndOutput(inputString)
            local mappedNames = {}
            for _, char in utf8.codes(inputString) do
                local mappedValue = characterToMemory[utf8.char(char)] or 0xFF
                table.insert(mappedNames, mappedValue)
            end
            if #mappedNames > 10 then
                mappedNames = {table.unpack(mappedNames, 1, 10)}
            end
            while #mappedNames < 10 do
                table.insert(mappedNames, 0xFF)
            end
            return mappedNames
        end
    
        --------------------------------------
        -- Conversion Function
        --
        -- Reads the first entry from the JSON names list,
        -- converts the "name" field to memory values, writes those bytes to the designated memory address,
        -- and then removes that entry from the list.
        --------------------------------------
        local function convertAndWriteToMemory()
            memory.usememorydomain("System Bus")
            local namesList = Resources.NamesList or {}
            if #namesList < 1 then
                print("No names available in the list.")
                return
            end
    
            local entry = namesList[1]
            local name = entry.name or ""
            local mappedNames = mapUTF8StringAndOutput(name)
            local address = 0x0202428C  -- US FRLG nickname memory address
    
            for _, value in ipairs(mappedNames) do
                memory.writebyte(address, value)
                local reader = memory.readbyte(address)
                if reader ~= value then
                    print("Error: Failed to write to memory at " .. string.format("0x%X", address))
                    return
                end
                address = address + 1
            end
    
            print("The name '" .. name .. "' has been recorded to the Pokémon.")
            table.remove(namesList, 1)
            Resources.NamesList = namesList
            self.saveNamesToFile(namesList)
        end
    
        --------------------------------------
        -- Options Dialog: Edit Names List Popup
        --
        -- Opens a BizHawk form showing each entry formatted as "Name - Namer" (one per line).
        -- Allows you to edit, save changes, or restore the default names list.
        --------------------------------------
        function self.openPopup()
            local x, y, w, h, lineHeight = 20, 15, 600, 405, 20
            local bottomPadding = 115
            local form = Utils.createBizhawkForm("Edit Names List", w, h, 80, 20)
    
            forms.label(form, "Edit entries or add new ones (format: Name - Namer), one per line:", x, y, w - 40, lineHeight)
            y = y + 20
    
            local lines = {}
            for _, entry in ipairs(Resources.NamesList or {}) do
                local nameStr = entry.name or ""
                local namerStr = entry.namer or ""
                table.insert(lines, nameStr .. " - " .. namerStr)
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
                        local nameStr = entry.name or ""
                        local namerStr = entry.namer or ""
                        table.insert(defaultLines, nameStr .. " - " .. namerStr)
                    end
                    forms.settext(namesTextBox, table.concat(defaultLines, NEWLINE))
                end
            end, x + 225, y)
            forms.button(form, Resources.AllScreens.Cancel, function()
                Utils.closeBizhawkForm(form)
            end, x + 335, y)
        end
    
        --------------------------------------
        -- Tracker Hooks & Extension Functions
        --------------------------------------
        -- When the Options button is clicked, open the names list editor popup.
        function self.configureOptions()
            self.openPopup()
        end
    
        -- On startup, load (or create) the JSON file into Resources.NamesList.
        function self.startup()
            self.DefaultNames = {}
            local filepath = self.getFilepathForNames()
            if not FileManager.fileExists(filepath) then
                -- Create an empty names file if it doesn't exist
                self.saveNamesToFile({})
                Resources.NamesList = {}
                print("Created new names file: " .. filepath)
            else
                local names = self.getNamesFromFile()
                Resources.NamesList = {}
                FileManager.copyTable(names, Resources.NamesList)
            end
            loopRun = true
        end
    
        -- On unload, optionally restore the default names list.
        function self.unload()
            if self.DefaultNames and #self.DefaultNames > 0 then
                Resources.NamesList = {}
                FileManager.copyTable(self.DefaultNames, Resources.NamesList)
                self.saveNamesToFile(self.DefaultNames)
            end
        end
    
        -- This function is called every 30 frames after program data is updated.
        -- When the game memory (at startAddress) indicates a condition, process the first names list entry.
        function self.afterProgramDataUpdate()
            local memCheck = memory.readbyte(startAddress)
            if memCheck > 0 then
                if loopRun then
                    -- Optionally add a check here to ensure the US FRLG game is loaded
                    convertAndWriteToMemory()
                    loopRun = false
                end
            elseif memCheck == 0 then
                loopRun = true
            end
        end
    
        --------------------------------------
        -- Chat & Reward Event Handlers
        --
        -- These functions allow the extension to respond to chat commands and reward events
        -- from the Tracker's chat connection.
        --------------------------------------
    function self.CommandEvent(message)
        -- Parse the incoming chat message (assumes a simple command format)
        local cmd, args = message:match("^(%S+)%s*(.*)")
        if cmd and cmd:lower() == "!ntp" then
            print("!ntp command received via chat. Processing name conversion.")
            convertAndWriteToMemory()
        end
    end
    
        function self.RewardEvent(reward, user)
            -- Check the reward text; if it matches criteria (e.g. contains "ntp"), process conversion.
            if reward and reward:lower():find("ntp") then
                print("Reward event triggered for user " .. (user or "unknown") .. ". Adding name to list!")
                convertAndWriteToMemory()
            end
        end
    
        -- Check for updates (optional)
        function self.checkForUpdates()
            local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"'
            local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github or "")
            local downloadUrl = string.format("%s/releases/latest", self.url or "")
            local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end
            local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
            return isUpdateAvailable, downloadUrl
        end
    
        return self
    end
    
    return CodeExtensionTemplate
    
    