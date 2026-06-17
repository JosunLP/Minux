-- top: live system dashboard
local args = { ... }

local function isHelpToken(t)
  return t == "help" or t == "-h" or t == "--help" or t == "?"
end

if isHelpToken(args[1]) then
  print("Usage: top")
  print("Show a system overview: ID, label, uptime, disk, peripherals, rednet.")
  return 0
end

local function withColor(color, fn)
  if term.isColor() then term.setTextColor(color) end
  fn()
  if term.isColor() then term.setTextColor(colors.white) end
end

local function centeredLine(text, char, color)
  char = char or "="
  local w = term.getSize()
  local content = " " .. text .. " "
  local pad = math.max(0, w - #content)
  local left  = math.floor(pad / 2)
  local right = pad - left
  withColor(color or colors.white, function()
    print(string.rep(char, left) .. content .. string.rep(char, right))
  end)
end

local function infoLine(label, value, valueColor)
  local w = term.getSize()
  local valStr = tostring(value)
  local prefix = "  " .. label
  local dotsLen = math.max(1, w - #prefix - #valStr - 2)
  write(prefix .. " " .. string.rep(".", dotsLen) .. " ")
  if valueColor then
    withColor(valueColor, function() print(valStr) end)
  else
    print(valStr)
  end
end

local function sectionHeader(title)
  local w = term.getSize()
  withColor(colors.cyan, function()
    print("  " .. title .. " " .. string.rep("-", math.max(0, w - #title - 4)))
  end)
end

-- Gather info
local id    = os.getComputerID()
local label = os.getComputerLabel() or ("computer-" .. id)
local up    = math.floor(os.clock())
local hours = math.floor(up / 3600)
local mins  = math.floor((up % 3600) / 60)
local secs  = up % 60

local function formatDisk(bytes)
  if bytes >= 1024 * 1024 then
    return string.format("%.1f MB", bytes / 1024 / 1024)
  elseif bytes >= 1024 then
    return string.format("%.1f KB", bytes / 1024)
  else
    return string.format("%d B", bytes)
  end
end

-- Render
term.clear()
term.setCursorPos(1, 1)

centeredLine("ReMinux  top", "=", colors.cyan)

print("")
sectionHeader("System")
infoLine("Computer", label, colors.white)
infoLine("ID", tostring(id), colors.gray)
infoLine("Version", (_G.version or "unknown"), colors.white)
infoLine("Uptime", string.format("%02d:%02d:%02d", hours, mins, secs), colors.lime)
infoLine("In-game", string.format("day %d, time %.1f", os.day(), os.time()), colors.gray)
if _HOST ~= nil then
  infoLine("Host", _HOST, colors.gray)
end

-- User info
if _G.login ~= nil then
  local userStr = tostring(_G.login)
  local userColor = colors.white
  if _G.admin == true then
    userStr = userStr .. " [admin]"
    userColor = colors.yellow
  end
  infoLine("User", userStr, userColor)
end

-- Disk
print("")
sectionHeader("Storage")
local free = fs.getFreeSpace and fs.getFreeSpace("/") or nil
if free ~= nil then
  local diskColor = colors.lime
  if free < 100 * 1024 then diskColor = colors.red
  elseif free < 500 * 1024 then diskColor = colors.yellow
  end
  infoLine("Free disk", formatDisk(free), diskColor)
  -- Mini usage bar
  local totalGuess = 1024 * 1024  -- CC default ~1 MB
  local usedPct = math.min(100, math.max(0, math.floor((1 - free / totalGuess) * 100)))
  local w = term.getSize()
  local barWidth = math.min(20, w - 16)
  local filled = math.floor(barWidth * usedPct / 100)
  local bar = string.rep("#", filled) .. string.rep(".", barWidth - filled)
  withColor(colors.gray, function()
    write("  Usage    ")
  end)
  local barColor = diskColor
  withColor(barColor, function() write("[" .. bar .. "]") end)
  withColor(colors.gray, function() print(" " .. usedPct .. "%") end)
end

-- Peripherals
print("")
sectionHeader("Peripherals")
if peripheral == nil then
  withColor(colors.gray, function() print("    (peripheral API unavailable)") end)
else
  local sides = peripheral.getNames()
  if #sides == 0 then
    withColor(colors.gray, function() print("    none attached") end)
  else
    table.sort(sides)
    for _, side in ipairs(sides) do
      local ptype = tostring(peripheral.getType(side))
      withColor(colors.gray, function() write("    " .. side) end)
      write(string.rep(" ", math.max(1, 18 - #side)))
      withColor(colors.white, function() print(ptype) end)
    end
  end
end

-- Rednet
if rednet ~= nil and rednet.isOpen ~= nil then
  print("")
  sectionHeader("Network")
  local found = false
  for _, side in ipairs({ "top", "bottom", "left", "right", "front", "back" }) do
    if rednet.isOpen(side) then
      withColor(colors.lime, function() print("    modem open: " .. side) end)
      found = true
    end
  end
  if not found then
    withColor(colors.gray, function() print("    no modems open") end)
  end
  if _G.server ~= nil and _G.server ~= "[none]" then
    infoLine("Server", _G.server, colors.lime)
  end
end

print("")
withColor(colors.cyan, function()
  local w = term.getSize()
  print(string.rep("=", w))
end)
