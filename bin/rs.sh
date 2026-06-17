-- rs: redstone control utility. Get/set/pulse signals on any side, list
-- the current state of all sides, or read bundled-cable colour states.
local args = { ... }

local function showHelp()
	print("Usage:")
	print("  rs                          Show the state of every side")
	print("  rs get <side>               Print on/off (and analog level)")
	print("  rs on <side>                Turn the side on")
	print("  rs off <side>               Turn the side off")
	print("  rs set <side> <0..15>       Set an analog signal level")
	print("  rs pulse <side> [seconds]   Pulse the side high (default 0.2s)")
	print("  rs bundled <side>           Read all 16 colours of a bundled cable")
end

if rs == nil and redstone == nil then
	print("rs: redstone API not available")
	return false
end
local api = rs or redstone

local SIDES = { "top", "bottom", "left", "right", "front", "back" }

local function isSide(name)
	for _, side in ipairs(SIDES) do
		if side == name then return true end
	end
	return false
end

if args[1] == nil or args[1] == "?" or args[1] == "help" then
	if args[1] == "?" or args[1] == "help" then showHelp() return 0 end
	print(string.format("%-8s %-3s %s", "Side", "On", "Analog"))
	print(string.rep("-", 22))
	for _, side in ipairs(SIDES) do
		local on  = api.getInput(side)
		local lvl = api.getAnalogInput and api.getAnalogInput(side) or (on and 15 or 0)
		print(string.format("%-8s %-3s %d", side, tostring(on), lvl))
	end
	return 0
end

local command = args[1]
local side = args[2]

if command == "get" then
	if isSide(side) == false then print("rs: invalid side") return false end
	local on  = api.getInput(side)
	local lvl = api.getAnalogInput and api.getAnalogInput(side) or (on and 15 or 0)
	print(string.format("%s: on=%s analog=%d", side, tostring(on), lvl))
elseif command == "on" then
	if isSide(side) == false then print("rs: invalid side") return false end
	api.setOutput(side, true)
elseif command == "off" then
	if isSide(side) == false then print("rs: invalid side") return false end
	api.setOutput(side, false)
elseif command == "set" then
	if isSide(side) == false then print("rs: invalid side") return false end
	local level = tonumber(args[3])
	if level == nil or level < 0 or level > 15 then
		print("rs: level must be 0..15") return false
	end
	if api.setAnalogOutput ~= nil then
		api.setAnalogOutput(side, math.floor(level))
	else
		api.setOutput(side, level > 0)
	end
elseif command == "pulse" then
	if isSide(side) == false then print("rs: invalid side") return false end
	local duration = tonumber(args[3]) or 0.2
	api.setOutput(side, true)
	sleep(duration)
	api.setOutput(side, false)
elseif command == "bundled" then
	if isSide(side) == false then print("rs: invalid side") return false end
	if api.getBundledInput == nil then
		print("rs: bundled cables not supported on this side")
		return false
	end
	local mask = api.getBundledInput(side)
	local colourNames = {
		"white","orange","magenta","lightBlue","yellow","lime","pink","gray",
		"lightGray","cyan","purple","blue","brown","green","red","black",
	}
	for index = 1, 16 do
		local colour = 2 ^ (index - 1)
		local on = bit32 and bit32.band(mask, colour) ~= 0 or false
		print(string.format("%-12s %s", colourNames[index], tostring(on)))
	end
else
	showHelp()
end
