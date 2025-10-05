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
    input_device_path = "/dev/input/event3",  -- Device path
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
    local config_path = "/mnt/onboard/.adds/koreader/plugins/bluetooth.koplugin/" .. self.bank_config_file
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
    local command = "/bin/sh /mnt/onboard/.adds/koreader/plugins/bluetooth.koplugin/" .. script
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
    local script = self:getScriptPath("off.sh")
    local result = self:executeScript(script)

    self.is_bluetooth_on = false
    self:popup(_("Bluetooth turned off."))
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

        Device.input.close(self.input_device_path) -- Close the input using the high-level parameter
        Device.input.open(self.input_device_path)  -- Reopen the input using the high-level parameter
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

function Bluetooth:popup(text)
    local popup = InfoMessage:new{
        text = text,
    }
    UIManager:show(popup)
end

function Bluetooth:isWifiEnabled()
    local handle = io.popen("iwconfig")
    local result = handle:read("*a")
    handle:close()

    -- Check if Wi-Fi is enabled by looking for 'ESSID'
    return result:match("ESSID") ~= nil
end


return Bluetooth
