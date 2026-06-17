-- neofetch: system info display in the style of the classic Unix tool.
local args = { ... }

local function isHelpToken(t)
  return t == "help" or t == "-h" or t == "--help" or t == "?"
end

if isHelpToken(args[1]) then
  print("Usage: neofetch")
  print("Display an ASCII art system summary.")
  return true
end

local function withColor(color, fn)
  if term.isColor() then term.setTextColor(color) end
  fn()
  if term.isColor() then term.setTextColor(colors.white) end
end

local w = term.getSize()

-- ASCII art logo (fits 26-col pocket & 51-col desktop)
local LOGO = {
  "  .---.  ",
  " /  ___\\ ",
  "| (___) |",
  " \\_____/ ",
  "  |   |  ",
  " /|   |\\ ",
}
local LOGO_COLOR = colors.cyan

-- Collect info
local id      = os.getComputerID()
local label   = os.getComputerLabel() or ("computer-" .. id)
local user    = _G.login or "guest"
local version = _G.version or "unknown"
local up      = math.floor(os.clock())
local upStr   = string.format("%dh %dm %ds",
  math.floor(up / 3600),
  math.floor((up % 3600) / 60),
  up % 60)
local ui      = (minux and minux.getconfig and minux.getconfig("ui")) or "unknown"
local login   = (minux and minux.getconfig and minux.getconfig("login")) or "unknown"

local function diskStr()
  local free = fs.getFreeSpace and fs.getFreeSpace("/") or nil
  if free == nil then return "unknown" end
  if free >= 1024 * 1024 then return string.format("%.1f MB free", free / 1024 / 1024)
  elseif free >= 1024    then return string.format("%.1f KB free", free / 1024)
  else                        return string.format("%d B free", free)
  end
end

local periphCount = 0
if peripheral ~= nil then
  periphCount = #peripheral.getNames()
end

-- Build info rows
local INFO_LABEL = colors.cyan
local INFO_VALUE = colors.white

local infoRows = {
  { label = "OS",         value = "ReMinux v" .. version },
  { label = "Host",       value = label .. "  (id=" .. id .. ")" },
  { label = "User",       value = user .. (_G.admin and " [admin]" or "") },
  { label = "Uptime",     value = upStr },
  { label = "UI",         value = ui },
  { label = "Login",      value = login },
  { label = "Disk",       value = diskStr() },
  { label = "Peripherals", value = tostring(periphCount) .. " attached" },
  { label = "Day",        value = string.format("day %d, time %.1f", os.day(), os.time()) },
}
if _HOST ~= nil then
  table.insert(infoRows, { label = "Host binary", value = _HOST })
end

-- Render
term.clear()
term.setCursorPos(1, 1)

local logoWidth = #(LOGO[1] or "")
local padding   = math.max(2, math.floor((w - logoWidth - 32) / 2))

-- Header: user@computer
local header = user .. "@" .. label
withColor(colors.cyan, function() print(string.rep("=", math.min(w, #header + 4))) end)
withColor(colors.white, function() print("  " .. header) end)
withColor(colors.cyan, function() print(string.rep("=", math.min(w, #header + 4))) end)
print("")

-- Logo + info side by side (only if terminal is wide enough)
local sideBySide = w >= 32
local maxRows = math.max(#LOGO, #infoRows)

for i = 1, maxRows do
  -- Logo column
  if sideBySide then
    if LOGO[i] then
      withColor(LOGO_COLOR, function() write(LOGO[i]) end)
    else
      write(string.rep(" ", logoWidth))
    end
    write("  ")
  end

  -- Info column
  if infoRows[i] then
    withColor(INFO_LABEL, function() write(string.format("%-12s", infoRows[i].label)) end)
    withColor(colors.gray, function() write(" : ") end)
    withColor(INFO_VALUE, function() write(infoRows[i].value) end)
  end
  print("")
end

-- Color palette (only on colour terminals)
if term.isColor() then
  print("")
  write("  ")
  local palette = {
    colors.black, colors.gray, colors.lightGray, colors.white,
    colors.red, colors.orange, colors.yellow, colors.lime,
    colors.green, colors.cyan, colors.lightBlue, colors.blue,
    colors.purple, colors.magenta, colors.pink, colors.brown,
  }
  for _, c in ipairs(palette) do
    term.setBackgroundColor(c)
    write("  ")
  end
  term.setBackgroundColor(colors.black)
  print("")
end

print("")
withColor(colors.cyan, function() print(string.rep("=", math.min(w, #header + 4))) end)
if term.isColor() then term.setTextColor(colors.white) end

return true
