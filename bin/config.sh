-- config: view and change ReMinux system settings
local args = { ... }
local config  = args[1]
local setting = args[2]

local validSettings = {
  login        = { "local", "network", "disabled" },
  encrypt      = { "enabled", "disabled" },
  clearlogin   = { "enabled", "disabled" },
  mapcleanup   = { "enabled", "disabled" },
  crashhandler = { "enabled", "disabled" },
  network      = { "enabled", "disabled" },
  welcome      = { "enabled", "disabled" },
  update       = { "always", "enabled", "disabled" },
  debug        = { "enabled", "disabled", "logging", "full" },
  ui           = { "menu", "prompt", "workspace", "craftos" },
  menu         = { "menu", "prompt", "workspace", "craftos" },
}

local listedKeys = {
  "login", "ui", "welcome", "update", "network", "debug",
  "crashhandler", "clearlogin", "encrypt", "mapcleanup",
}

local function isValidValue(key, value)
  if validSettings[key] == nil or value == nil then return false end
  for _, candidate in ipairs(validSettings[key]) do
    if candidate == value then return true end
  end
  return false
end

local function joinOptions(key)
  return table.concat(validSettings[key], " | ")
end

local function formatBool(value)
  if value == true then return "enabled"
  elseif value == false then return "disabled"
  else return tostring(value) end
end

local function readCurrent(key)
  return formatBool(minux.getconfig(key))
end

local function withColor(color, fn)
  if term.isColor() then term.setTextColor(color) end
  fn()
  if term.isColor() then term.setTextColor(colors.white) end
end

local function isHelpToken(token)
  return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function printUsage()
  local w = term.getSize()
  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
  withColor(colors.white, function() print("  config  -  ReMinux settings") end)
  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
  withColor(colors.gray, function()
    print("  config                 list all current settings")
    print("  config <key>           show value and options for a key")
    print("  config <key> <value>   change a setting")
    print("  config help            show this message")
  end)
  print("")
  withColor(colors.cyan, function() print("  Available keys:") end)
  for _, key in ipairs(listedKeys) do
    withColor(colors.white, function() write(string.format("    %-13s", key)) end)
    withColor(colors.gray, function() print(joinOptions(key)) end)
  end
  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
  withColor(colors.gray, function() print("  See 'man config' for details.") end)
end

local function valueColor(key, value)
  -- Color-code specific value types
  if value == "enabled" or value == "local" or value == "always" then
    return colors.lime
  elseif value == "disabled" then
    return colors.gray
  elseif value == "network" then
    return colors.cyan
  else
    return colors.white
  end
end

local function printSettingsList()
  local w = term.getSize()
  withColor(colors.cyan, function()
    print(string.rep("=", math.min(w, 51)))
    print("  ReMinux configuration")
    print(string.rep("=", math.min(w, 51)))
  end)
  for _, key in ipairs(listedKeys) do
    local val = readCurrent(key)
    local valStr = "[ " .. val .. " ]"
    local prefix = "  " .. key
    local dotsLen = math.max(1, math.min(w, 51) - #prefix - #valStr - 2)
    withColor(colors.white, function() write(prefix) end)
    withColor(colors.gray, function() write(" " .. string.rep(".", dotsLen) .. " ") end)
    withColor(valueColor(key, val), function() print(valStr) end)
  end
  withColor(colors.cyan, function() print(string.rep("=", math.min(w, 51))) end)
  withColor(colors.gray, function()
    print("  'config <key>' for options  |  'config help' for usage")
  end)
end

local function printKeyHelp(key)
  local val = readCurrent(key)
  local w = term.getSize()
  withColor(colors.cyan, function()
    print(string.rep("-", math.min(w, 40)))
  end)
  withColor(colors.white, function() print("  config: " .. key) end)
  write("  current : ")
  withColor(valueColor(key, val), function() print(val) end)
  withColor(colors.gray, function()
    print("  options : " .. joinOptions(key))
    print("  set via : config " .. key .. " <value>")
  end)
  withColor(colors.cyan, function()
    print(string.rep("-", math.min(w, 40)))
  end)
end

-- Dispatch
if config ~= nil and isHelpToken(config) then
  printUsage()
  return true
end

if config == nil then
  if apt and apt.checkinstall and apt.checkinstall("menu") == true then
    shell.run("/etc/minux-main/menu/config.sys")
    return true
  end
  printSettingsList()
  return true
end

if validSettings[config] == nil then
  withColor(colors.red, function()
    print("config: unknown setting '" .. tostring(config) .. "'")
  end)
  print("")
  printUsage()
  return false
end

if setting == nil or isHelpToken(setting) then
  printKeyHelp(config)
  return true
end

if not isValidValue(config, setting) then
  withColor(colors.red, function()
    print("config: invalid value '" .. tostring(setting) .. "' for '" .. config .. "'")
  end)
  withColor(colors.gray, function()
    print("Valid options: " .. joinOptions(config))
  end)
  return false
end

local ok = minux.setconfig(config, setting)
if ok ~= true then
  withColor(colors.red, function()
    print("config: failed to apply '" .. config .. " = " .. setting .. "'")
  end)
  withColor(colors.gray, function()
    print("This may require admin or owner privileges. See 'man config'.")
  end)
  return false
end

withColor(colors.lime, function()
  print("config: " .. config .. " = " .. setting)
end)
return true
