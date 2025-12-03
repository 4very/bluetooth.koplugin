--[[--
This is a plugin to manage Bluetooth.

@module koplugin.Bluetooth
--]]--

local Dispatcher = require("dispatcher")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local InputContainer = require("ui/widget/container/inputcontainer")
local Device = require("device")
local EventListener = require("ui/widget/eventlistener")
local Event = require("ui/event")  -- Add this line

-- local BTKeyManager = require("BTKeyManager")

local _ = require("gettext")

-- local Bluetooth = EventListener:extend{
local Bluetooth = InputContainer:extend{
    name = "Bluetooth",
    is_bluetooth_on = false,  -- Tracks the state of Bluetooth
    input_device_path = "/dev/input/event4",  -- Device path
    current_bank = 1,  -- Current bank (1-based)
    banks = {},  -- Bank configurations
    bank_config_file = "bank_config.txt",  -- Bank configuration file
}

function Bluetooth:onDispatcherRegisterActions()
    Dispatcher:registerAction("bluetooth_on_action", {category="none", event="BluetoothOn", title=_("Bluetooth On"), general=true})
    Dispatcher:registerAction("bluetooth_off_action", {category="none", event="BluetoothOff", title=_("Bluetooth Off"), general=true})
    Dispatcher:registerAction("refresh_pairing_action", {category="none", event="RefreshPairing", title=_("Refresh Device Input"), general=true}) -- New action
    Dispatcher:registerAction("connect_to_device_action", {category="none", event="ConnectToDevice", title=_("Connect to Device"), general=true}) -- New action
end

function Bluetooth:registerKeyEvents()
    self.key_events.BTGotoNextChapter = { { "BTGotoNextChapter" }, event = "BTGotoNextChapter" }
    self.key_events.BTGotoPrevChapter = { { "BTGotoPrevChapter" }, event = "BTGotoPrevChapter" }
    self.key_events.BTDecreaseFontSize = { { "BTDecreaseFontSize" }, event = "BTDecreaseFontSize" }
    self.key_events.BTIncreaseFontSize = { { "BTIncreaseFontSize" }, event = "BTIncreaseFontSize" }
    self.key_events.BTToggleBookmark = { { "BTToggleBookmark" }, event = "BTToggleBookmark" }
    self.key_events.BTIterateRotation = { { "BTIterateRotation" }, event = "BTIterateRotation" }
    self.key_events.BTBluetoothOff = { { "BTBluetoothOff" }, event = "BTBluetoothOff" }
    self.key_events.BTRight = { { "BTRight" }, event = "BTRight" }
    self.key_events.BTLeft = { { "BTLeft" }, event = "BTLeft" }
	self.key_events.BTIncreaseBrightness = { { "BTIncreaseBrightness" }, event = "BTIncreaseBrightness" }
	self.key_events.BTDecreaseBrightness = { { "BTDecreaseBrightness" }, event = "BTDecreaseBrightness" }
	self.key_events.BTIncreaseWarmth = { { "BTIncreaseWarmth" }, event = "BTIncreaseWarmth" }
	self.key_events.BTDecreaseWarmth = { { "BTDecreaseWarmth" }, event = "BTDecreaseWarmth" }
	self.key_events.BTNextBookmark = { { "BTNextBookmark" }, event = "BTNextBookmark" }
	self.key_events.BTPrevBookmark = { { "BTPrevBookmark" }, event = "BTPrevBookmark" }
	self.key_events.BTLastBookmark = { { "BTLastBookmark" }, event = "BTLastBookmark" }
	self.key_events.BTToggleNightMode = { { "BTToggleNightMode" }, event = "BTToggleNightMode" }
	self.key_events.BTToggleStatusBar = { { "BTToggleStatusBar" }, event = "BTToggleStatusBar" }
	
	-- Sleep and shutdown
	self.key_events.BTSleep = { { "BTSleep" }, event = "BTSleep" }
	self.key_events.BTBluetoothOffAndSleep = { { "BTBluetoothOffAndSleep" }, event = "BTBluetoothOffAndSleep" }
	
	-- Screen refresh
	self.key_events.BTRefreshScreen = { { "BTRefreshScreen" }, event = "BTRefreshScreen" }
	
	-- Font settings cycling
	self.key_events.BTCycleFontHinting = { { "BTCycleFontHinting" }, event = "BTCycleFontHinting" }
	self.key_events.BTCycleFontKerning = { { "BTCycleFontKerning" }, event = "BTCycleFontKerning" }
	self.key_events.BTCycleWordSpacing = { { "BTCycleWordSpacing" }, event = "BTCycleWordSpacing" }
	self.key_events.BTCycleWordExpansion = { { "BTCycleWordExpansion" }, event = "BTCycleWordExpansion" }
	
	-- Font weight increase/decrease
	self.key_events.BTIncreaseFontWeight = { { "BTIncreaseFontWeight" }, event = "BTIncreaseFontWeight" }
	self.key_events.BTDecreaseFontWeight = { { "BTDecreaseFontWeight" }, event = "BTDecreaseFontWeight" }
	
	-- Line spacing increase/decrease
	self.key_events.BTIncreaseLineSpacing = { { "BTIncreaseLineSpacing" }, event = "BTIncreaseLineSpacing" }
	self.key_events.BTDecreaseLineSpacing = { { "BTDecreaseLineSpacing" }, event = "BTDecreaseLineSpacing" }
	
	-- Bank navigation
	self.key_events.BTRemoteNextBank = { { "BTRemoteNextBank" }, event = "BTRemoteNextBank" }
	self.key_events.BTRemotePrevBank = { { "BTRemotePrevBank" }, event = "BTRemotePrevBank" }
	
	-- Bank action mapping (BTAction1-20)
	for i = 1, 20 do
		self.key_events["BTAction" .. i] = { { "BTAction" .. i }, event = "BTAction" .. i }
	end
	
end


function Bluetooth:onBTGotoNextChapter()
    UIManager:sendEvent(Event:new("GotoNextChapter"))
end

function Bluetooth:onBTGotoPrevChapter()
    UIManager:sendEvent(Event:new("GotoPrevChapter"))
end

function Bluetooth:onBTDecreaseFontSize()
    UIManager:sendEvent(Event:new("DecreaseFontSize", 2))
end

function Bluetooth:onBTIncreaseFontSize()
    UIManager:sendEvent(Event:new("IncreaseFontSize", 2))
end

function Bluetooth:onBTToggleBookmark()
    UIManager:sendEvent(Event:new("ToggleBookmark"))
end

function Bluetooth:onBTIterateRotation()
    UIManager:sendEvent(Event:new("IterateRotation"))
end

function Bluetooth:onBTBluetoothOff()
    UIManager:sendEvent(Event:new("BluetoothOff"))
end

function Bluetooth:onBTRight()
    UIManager:sendEvent(Event:new("GotoViewRel", 1))
end

function Bluetooth:onBTLeft()
    UIManager:sendEvent(Event:new("GotoViewRel", -1))
end

function Bluetooth:onBTIncreaseBrightness()
    UIManager:sendEvent(Event:new("IncreaseFlIntensity", 10))
end

function Bluetooth:onBTDecreaseBrightness()
    UIManager:sendEvent(Event:new("DecreaseFlIntensity", 10))
end

function Bluetooth:onBTIncreaseWarmth()
    UIManager:sendEvent(Event:new("IncreaseFlWarmth", 1))
end

function Bluetooth:onBTDecreaseWarmth()
    UIManager:sendEvent(Event:new("IncreaseFlWarmth", -1))
end

function Bluetooth:onBTNextBookmark()
    UIManager:sendEvent(Event:new("GotoNextBookmarkFromPage"))
end

function Bluetooth:onBTPrevBookmark()
    UIManager:sendEvent(Event:new("GotoPreviousBookmarkFromPage"))
end

function Bluetooth:onBTLastBookmark()
    UIManager:sendEvent(Event:new("GoToLatestBookmark"))
end

function Bluetooth:onBTToggleNightMode()
    UIManager:sendEvent(Event:new("ToggleNightMode"))
end

function Bluetooth:onBTToggleStatusBar()
    UIManager:sendEvent(Event:new("ToggleFooterMode"))
end

function Bluetooth:onBTSleep()
    UIManager:suspend()
end

function Bluetooth:onBTRefreshScreen()
    UIManager:setDirty("all", "full")
end

function Bluetooth:onBTBluetoothOffAndSleep()
    -- Turn off Bluetooth first (without popup)
    self:turnOffBluetooth()
    
    -- Wait 1 second, then put device to sleep
    UIManager:scheduleIn(1, function()
        UIManager:suspend()
    end)
end

-- Font settings cycling functions
function Bluetooth:onBTCycleFontHinting()
    self:cycleFontSetting("font_hinting", {0, 1, 2}, {"off", "native", "auto"})
end

function Bluetooth:onBTCycleFontKerning()
    self:cycleFontSetting("font_kerning", {0, 1, 2, 3}, {"off", "fast", "good", "best"})
end

function Bluetooth:onBTCycleWordSpacing()
    self:cycleWordSpacing()
end

function Bluetooth:onBTCycleWordExpansion()
    self:cycleFontSetting("word_expansion", {0, 5, 15}, {"none", "some", "more"})
end

function Bluetooth:onBTIncreaseFontWeight()
    self:adjustFontWeight(0.5)
end

function Bluetooth:onBTDecreaseFontWeight()
    self:adjustFontWeight(-0.5)
end

function Bluetooth:onBTIncreaseLineSpacing()
    self:adjustLineSpacing(5)
end

function Bluetooth:onBTDecreaseLineSpacing()
    self:adjustLineSpacing(-5)
end

-- Bank navigation functions
function Bluetooth:onBTRemoteNextBank()
    self:nextBank()
end

function Bluetooth:onBTRemotePrevBank()
    self:prevBank()
end

-- Bank action mapping functions (BTAction1-20)
function Bluetooth:onBTAction1() self:executeBankAction(1) end
function Bluetooth:onBTAction2() self:executeBankAction(2) end
function Bluetooth:onBTAction3() self:executeBankAction(3) end
function Bluetooth:onBTAction4() self:executeBankAction(4) end
function Bluetooth:onBTAction5() self:executeBankAction(5) end
function Bluetooth:onBTAction6() self:executeBankAction(6) end
function Bluetooth:onBTAction7() self:executeBankAction(7) end
function Bluetooth:onBTAction8() self:executeBankAction(8) end
function Bluetooth:onBTAction9() self:executeBankAction(9) end
function Bluetooth:onBTAction10() self:executeBankAction(10) end
function Bluetooth:onBTAction11() self:executeBankAction(11) end
function Bluetooth:onBTAction12() self:executeBankAction(12) end
function Bluetooth:onBTAction13() self:executeBankAction(13) end
function Bluetooth:onBTAction14() self:executeBankAction(14) end
function Bluetooth:onBTAction15() self:executeBankAction(15) end
function Bluetooth:onBTAction16() self:executeBankAction(16) end
function Bluetooth:onBTAction17() self:executeBankAction(17) end
function Bluetooth:onBTAction18() self:executeBankAction(18) end
function Bluetooth:onBTAction19() self:executeBankAction(19) end
function Bluetooth:onBTAction20() self:executeBankAction(20) end

-- BTNone function for empty slots
function Bluetooth:onBTNone()
    -- Do nothing for empty action slots
end

-- Helper function to cycle through font settings
function Bluetooth:cycleFontSetting(setting_name, values, labels)
    -- Get the current reader UI and font module
    local readerui = self.ui
    if not readerui or not readerui.font then
        return
    end
    
    local current_value = readerui.font.configurable[setting_name]
    local current_index = 1
    
    -- Find current index
    for i, value in ipairs(values) do
        if value == current_value then
            current_index = i
            break
        end
    end
    
    -- Cycle to next value
    local next_index = (current_index % #values) + 1
    local next_value = values[next_index]
    
    -- Apply the new setting
    if setting_name == "font_hinting" then
        readerui.font:onSetFontHinting(next_value)
    elseif setting_name == "font_kerning" then
        readerui.font:onSetFontKerning(next_value)
    elseif setting_name == "word_expansion" then
        readerui.font:onSetWordExpansion(next_value)
    end
end

-- Special function for word spacing (handles array values)
function Bluetooth:cycleWordSpacing()
    local readerui = self.ui
    if not readerui or not readerui.font then
        return
    end
    
    local spacing_values = {{75, 50}, {95, 75}, {100, 90}}
    local current_value = readerui.font.configurable.word_spacing
    local current_index = 1
    
    -- Find current index
    for i, value in ipairs(spacing_values) do
        if value[1] == current_value[1] and value[2] == current_value[2] then
            current_index = i
            break
        end
    end
    
    -- Cycle to next value
    local next_index = (current_index % #spacing_values) + 1
    local next_value = spacing_values[next_index]
    
    -- Apply the new setting
    readerui.font:onSetWordSpacing(next_value)
end

-- Helper function to adjust font weight
function Bluetooth:adjustFontWeight(delta)
    local readerui = self.ui
    if not readerui or not readerui.font then
        return
    end
    
    local current_weight = readerui.font.configurable.font_base_weight
    local new_weight = current_weight + delta
    
    -- Clamp the weight to reasonable bounds (-3 to 5.5 as per creoptions.lua)
    new_weight = math.max(-3, math.min(5.5, new_weight))
    
    -- Apply the new weight
    readerui.font:onSetFontBaseWeight(new_weight)
end

-- Helper function to adjust line spacing
function Bluetooth:adjustLineSpacing(delta)
    local readerui = self.ui
    if not readerui or not readerui.font then
        return
    end
    
    local current_spacing = readerui.font.configurable.line_spacing
    local new_spacing = current_spacing + delta
    
    -- Clamp the spacing to reasonable bounds (50 to 200 as per creoptions.lua)
    new_spacing = math.max(50, math.min(200, new_spacing))
    
    -- Apply the new spacing
    readerui.font:onSetLineSpace(new_spacing)
end

-- Bank system functions
function Bluetooth:loadBankConfig()
    local config_path = self.path .. "/" .. self.bank_config_file
    local file = io.open(config_path, "r")
    if not file then
        return
    end
    
    local content = file:read("*all")
    file:close()
    
    self.banks = {}
    local current_bank = nil
    local bank_number = 0
    
    for line in content:gmatch("[^\r\n]+") do
        line = line:gsub("^%s*", ""):gsub("%s*$", "") -- trim whitespace
        if line == "" then goto continue end
        
        if line:match("^Bank%d+$") then
            bank_number = tonumber(line:match("Bank(%d+)"))
            current_bank = {}
            self.banks[bank_number] = current_bank
        elseif line:match("^BTAction%d+:") and current_bank then
            local action_num = tonumber(line:match("BTAction(%d+)"))
            local target_event = line:match("BTAction%d+:(.+)")
            -- Remove anything after comma (comments)
            if target_event then
                target_event = target_event:match("([^,]+)") or target_event
                target_event = target_event:gsub("^%s*", ""):gsub("%s*$", "") -- trim whitespace
            end
            current_bank[action_num] = target_event
        end
        
        ::continue::
    end
    
    -- Load current bank from settings
    self.current_bank = G_reader_settings:readSetting("bluetooth_current_bank") or 1
    if not self.banks[self.current_bank] then
        self.current_bank = 1
    end
end


function Bluetooth:nextBank()
    local max_bank = 0
    for bank_num, _ in pairs(self.banks) do
        max_bank = math.max(max_bank, bank_num)
    end
    
    if max_bank > 0 then
        self.current_bank = (self.current_bank % max_bank) + 1
        G_reader_settings:saveSetting("bluetooth_current_bank", self.current_bank)
    end
end

function Bluetooth:prevBank()
    local max_bank = 0
    for bank_num, _ in pairs(self.banks) do
        max_bank = math.max(max_bank, bank_num)
    end
    
    if max_bank > 0 then
        self.current_bank = self.current_bank - 1
        if self.current_bank < 1 then
            self.current_bank = max_bank
        end
        G_reader_settings:saveSetting("bluetooth_current_bank", self.current_bank)
    end
end

function Bluetooth:executeBankAction(action_num)
    local current_bank_config = self.banks[self.current_bank]
    if not current_bank_config then return end
    
    local target_event = current_bank_config[action_num]
    if not target_event then return end
    
    -- Execute the mapped event
    if self["on" .. target_event] then
        self["on" .. target_event](self)
    end
end


function Bluetooth:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)

    self:registerKeyEvents()
    self:loadBankConfig()
end

function Bluetooth:addToMainMenu(menu_items)
    menu_items.bluetooth = {
        text = _("Bluetooth"),
        sorting_hint = "network",
        sub_item_table = {
            {
                text = _("Full Setup (WiFi + BT + Connect + Refresh)"),
                callback = function()
                    self:onFullBluetoothSetup()
                end,
            },
            {
                text = _("Wifi Up & Bluetooth On"),
                callback = function()
                    self:onWifiUpAndBluetoothOn()
                end,
            },
            {
                text = _("Bluetooth on"),
                callback = function()
                    if not self:isWifiEnabled() then
                        self:popup("Please turn on Wi-Fi to continue.")
                    else
                        self:onBluetoothOn()
                    end
                end,
            },
            {
                text = _("Bluetooth off"),
                callback = function()
                    self:onBluetoothOff()
                end,
            },
            {
                text = _("Reconnect to Device"),
                callback = function()
                    self:onConnectToDevice()
                end,
            },
            {
                text = _("Refresh Device Input"), -- New menu item
                callback = function()
                    self:onRefreshPairing()
                end,
            },
        },
    }
end

function Bluetooth:getScriptPath(script)
    return script
end

function Bluetooth:executeScript(script)
    local command = "/bin/sh " .. self.path .. "/" .. script
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

function Bluetooth:onBluetoothOn()
    local script = self:getScriptPath("on.sh")
    local result = self:executeScript(script)

    if not result or result == "" then
        self:popup(_("Error: No result from the Bluetooth script"))
        self.is_bluetooth_on = false
        return
    end

    if result:match("complete") then
        self.is_bluetooth_on = true
        self:popup(_("Bluetooth turned on."))
    else
        self:popup(_("Result: ") .. result)
        self.is_bluetooth_on = false
    end
end

function Bluetooth:onBluetoothOff()
    self:turnOffBluetooth()
    self:popup(_("Bluetooth turned off."))
end

function Bluetooth:turnOffBluetooth()
    local script = self:getScriptPath("off.sh")
    local result = self:executeScript(script)
    self.is_bluetooth_on = false
end

function Bluetooth:onRefreshPairing()
    if not self.is_bluetooth_on then
        self:popup(_("Bluetooth is off. Please turn it on before refreshing pairing."))
        return
    end

    local status, err = pcall(function()
        -- Ensure the device path is valid
        if not self.input_device_path or self.input_device_path == "" then
            error("Invalid device path")
        end

        Device.input:close(self.input_device_path) -- Close the input using the high-level parameter
        Device.input:open(self.input_device_path)  -- Reopen the input using the high-level parameter
        self:popup(_("Bluetooth device at ") .. self.input_device_path .. " is now open.")
    end)

    if not status then
        self:popup(_("Error: ") .. err)
    end
end

function Bluetooth:onConnectToDevice()
    if not self.is_bluetooth_on then
        self:popup(_("Bluetooth is off. Please turn it on before connecting to a device."))
        return
    end

    local script = self:getScriptPath("connect.sh")
    local result = self:executeScript(script)

    -- Simplify the message: focus on the success and device name
    local device_name = result:match("Name:%s*(.-)\n")  -- Extract the device name
    local success = result:match("Connection successful")  -- Check if connection was successful

    if success and device_name then
        self:popup(_("Connection successful: ") .. device_name)
    else
        self:popup(_("Result: ") .. result)  -- Show full result for debugging if something goes wrong
    end
end


function Bluetooth:debugPopup(msg)
    self:popup(_("DEBUG: ") .. msg)
end

function Bluetooth:popup(text, timeout)
    timeout = timeout or 2  -- Default 2 seconds
    local popup = InfoMessage:new{
        text = text,
    }
    UIManager:show(popup)
    -- Auto-dismiss after timeout
    UIManager:scheduleIn(timeout, function()
        UIManager:close(popup)
    end)
end

function Bluetooth:isWifiEnabled()
    local handle = io.popen("iwconfig")
    local result = handle:read("*a")
    handle:close()

    -- Check if Wi-Fi is enabled by looking for 'ESSID'
    return result:match("ESSID") ~= nil
end

function Bluetooth:enableWifi()
    -- Use the exact path provided
    local enable_wifi_script = "/mnt/onboard/.koreader/enable-wifi.sh"
    
    -- Check if script exists
    local file = io.open(enable_wifi_script, "r")
    if not file then
        return false, "Could not find enable-wifi.sh at " .. enable_wifi_script
    end
    file:close()
    
    -- Execute the script from its directory
    local command = string.format("sh -c 'cd /mnt/onboard/.koreader && ./enable-wifi.sh'")
    
    local result = os.execute(command)
    if result == 0 then
        return true, "WiFi enabled successfully"
    else
        return false, "Failed to enable WiFi (exit code: " .. tostring(result) .. ")"
    end
end

function Bluetooth:disableWifi()
    -- Use the exact path provided
    local disable_wifi_script = "/mnt/onboard/.koreader/disable-wifi.sh"
    
    -- Check if script exists
    local file = io.open(disable_wifi_script, "r")
    if not file then
        return false, "Could not find disable-wifi.sh at " .. disable_wifi_script
    end
    file:close()
    
    -- Execute the script from its directory
    local command = string.format("sh -c 'cd /mnt/onboard/.koreader && ./disable-wifi.sh'")
    
    local result = os.execute(command)
    if result == 0 then
        return true, "WiFi disabled successfully"
    else
        return false, "Failed to disable WiFi (exit code: " .. tostring(result) .. ")"
    end
end

function Bluetooth:onWifiUpAndBluetoothOn()
    -- First enable WiFi
    local success, message = self:enableWifi()
    if not success then
        self:popup(_("Failed to enable WiFi: ") .. message)
        return
    end
    
    -- Wait a moment for WiFi to initialize
    UIManager:scheduleIn(1, function()
        -- Now turn on Bluetooth
        self:onBluetoothOn()
    end)
    
    self:popup(_("WiFi enabled. Turning on Bluetooth..."))
end

function Bluetooth:onFullBluetoothSetup()
    -- Step 1: Enable WiFi
    self:popup(_("Step 1: Enabling WiFi..."), 4)
    local success, message = self:enableWifi()
    if not success then
        self:popup(_("Failed to enable WiFi: ") .. message, 4)
        return
    end
    
    -- Wait a bit, then show completion and move to next step
    UIManager:scheduleIn(1, function()
        self:popup(_("✓ WiFi enabled"), 2)
        
        -- Step 2: Enable Bluetooth
        UIManager:scheduleIn(1, function()
            self:popup(_("Step 2: Turning on Bluetooth..."), 4)
            local script = self:getScriptPath("on.sh")
            local result = self:executeScript(script)
            
            if not result or result == "" then
                self:popup(_("Error: No result from Bluetooth script"), 4)
                return
            end
            
            if not result:match("complete") then
                self:popup(_("Bluetooth error: ") .. result, 4)
                return
            end
            
            self.is_bluetooth_on = true
            
            -- Wait a bit, then show completion and move to next step
            UIManager:scheduleIn(1, function()
                self:popup(_("✓ Bluetooth enabled"), 2)
                
                -- Step 3: Connect to device
                UIManager:scheduleIn(1, function()
                    self:popup(_("Step 3: Connecting to device..."), 4)
                    local connect_script = self:getScriptPath("connect.sh")
                    local connect_result = self:executeScript(connect_script)
                    
                    -- Wait a bit, then show completion and move to next step
                    UIManager:scheduleIn(1, function()
                        self:popup(_("✓ Device connected"), 2)
                        
                        -- Step 4: Refresh device input
                        UIManager:scheduleIn(1, function()
                            self:popup(_("Step 4: Refreshing device input..."), 4)
                            local status, err = pcall(function()
                                if not self.input_device_path or self.input_device_path == "" then
                                    error("Invalid device path")
                                end
                                Device.input:close(self.input_device_path)
                                Device.input:open(self.input_device_path)
                            end)
                            
                            if status then
                                UIManager:scheduleIn(1, function()
                                    self:popup(_("✓ Device input refreshed"), 2)
                                    
                                    -- Step 5: Disable WiFi
                                    UIManager:scheduleIn(1, function()
                                        self:popup(_("Step 5: Disabling WiFi..."), 4)
                                        local wifi_success, wifi_message = self:disableWifi()
                                        
                                        if wifi_success then
                                            UIManager:scheduleIn(1, function()
                                                self:popup(_("✓ All done! Bluetooth ready, WiFi disabled."), 4)
                                            end)
                                        else
                                            self:popup(_("WiFi disable warning: ") .. wifi_message, 4)
                                            -- Still show success since Bluetooth is working
                                            UIManager:scheduleIn(1, function()
                                                self:popup(_("✓ Bluetooth ready (WiFi may still be on)"), 4)
                                            end)
                                        end
                                    end)
                                end)
                            else
                                self:popup(_("Error refreshing input: ") .. err, 4)
                            end
                        end)
                    end)
                end)
            end)
        end)
    end)
end


return Bluetooth
