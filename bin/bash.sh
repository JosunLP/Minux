-- bash shell launcher
local args = { ... }
local command = args[1]

local validColours = {
white = true, orange = true, magenta = true, lightBlue = true,
yellow = true, lime = true, pink = true, gray = true,
lightGray = true, cyan = true, purple = true, blue = true,
brown = true, green = true, red = true, black = true,
}

local function isHelpToken(token)
return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function withColor(color, callback)
if term.isColor() then term.setTextColor(color) end
callback()
if term.isColor() then term.setTextColor(colors.white) end
end

local function printUsage()
print("Usage: bash [command]                 launch the ReMinux shell")
print("       bash setcolor <text> <bg> <prompt>")
print("                                      set bash colour theme")
print("       bash help|-h|--help|?          show this message")
print("Colours are CC: Tweaked colour names (white, gray, red, ...).")
print("See 'man bash' for the full list and details.")
end

if command ~= nil and isHelpToken(command) then
printUsage()
return true
end

if command == "setcolor" then
local txtcolor = args[2]
local bgcolor  = args[3]
local prmcolor = args[4]
if txtcolor == nil or bgcolor == nil or prmcolor == nil then
withColor(colors.red, function()
print("bash setcolor: missing colour argument")
end)
print("Usage: bash setcolor <text> <bg> <prompt>")
return false
end
local invalid = nil
for _, candidate in ipairs({ txtcolor, bgcolor, prmcolor }) do
if not validColours[candidate] then invalid = candidate; break end
end
if invalid ~= nil then
withColor(colors.red, function()
print("bash setcolor: unknown colour '" .. tostring(invalid) .. "'")
end)
print("Use a CC: Tweaked colour name (e.g. white, gray, red, lime).")
return false
end
local ok = minux.bashcolor(txtcolor, bgcolor, prmcolor)
if ok ~= true then
withColor(colors.red, function()
print("bash setcolor: failed to write colour configuration")
end)
return false
end
withColor(colors.lime, function()
print(string.format("bash: colours set (text=%s bg=%s prompt=%s)",
txtcolor, bgcolor, prmcolor))
end)
return true
end

shell.run("/etc/minux-main/workspace/shell.lua", command)
