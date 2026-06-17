-- ReMinux bootloader

-- Determine the installed version from the package manifest.
local VERSION_DB = "/etc/apt/list/minux-main.db"
if fs.exists(VERSION_DB) then
  local temp = fs.open(VERSION_DB, "r")
  local line = temp.readLine()
  while line ~= nil do
    if string.find(line, "version=") == 1 then
      _G.version = string.sub(line, 9)
      break
    end
    line = temp.readLine()
  end
  temp.close()
end
if _G.version == nil then _G.version = "Unknown" end

-- Animated splash screen
term.clear()
term.setCursorPos(1, 1)

local w, h = term.getSize()
local centerRow = math.max(1, math.floor(h / 2) - 1)

local header = "ReMinux v" .. _G.version
local headerPad = math.max(0, math.floor((w - #header) / 2))

-- Draw top border
if term.isColor() then term.setTextColor(colors.cyan) end
term.setCursorPos(1, centerRow - 1)
print(string.rep("=", w))

-- Draw title
term.setCursorPos(headerPad + 1, centerRow)
if term.isColor() then term.setTextColor(colors.white) end
write(header)

-- Draw bottom border
if term.isColor() then term.setTextColor(colors.cyan) end
term.setCursorPos(1, centerRow + 1)
print(string.rep("=", w))

-- Animated loading dots
if term.isColor() then term.setTextColor(colors.gray) end
local dotRow = centerRow + 3
term.setCursorPos(1, dotRow)
local SPIN = { "|", "/", "-", "\\" }
local label = "  Initializing "
write(label)
local dotCol = #label + 1
for i = 1, 10 do
  term.setCursorPos(dotCol, dotRow)
  if term.isColor() then term.setTextColor(colors.yellow) end
  write(SPIN[((i - 1) % #SPIN) + 1])
  if term.isColor() then term.setTextColor(colors.gray) end
  os.sleep(0.06)
end

if term.isColor() then term.setTextColor(colors.white) end
term.clear()
term.setCursorPos(1, 1)

shell.run("/boot/init.sys")
