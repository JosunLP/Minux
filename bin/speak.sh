-- speak: speak text through an attached speaker peripheral.
-- Falls back to plain text output if the speaker has no speech synthesis
-- (which is the case for the vanilla CC: Tweaked speaker block).
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" then
	print("Usage: speak [side] <text...>")
	print("Plays a click-tone on a speaker for each word, and prints the")
	print("text. If <side> is the side of an attached speaker, that one is")
	print("used; otherwise the first speaker found is auto-selected.")
	return 0
end

if peripheral == nil then
	print("speak: peripheral API not available")
	return false
end

local side, text
if peripheral.getType(args[1]) == "speaker" then
	side = args[1]
	text = table.concat(args, " ", 2)
else
	side = peripheral.find ~= nil and (function()
		for _, name in ipairs(peripheral.getNames()) do
			if peripheral.getType(name) == "speaker" then return name end
		end
	end)() or nil
	text = table.concat(args, " ")
end

if side == nil then
	print(text)
	print("(no speaker attached - text printed instead)")
	return 0
end

local speaker = peripheral.wrap(side)
print(text)

-- Vanilla CC speakers don't synthesise speech; emit one note per word so
-- the user gets audible feedback that the speak command is alive.
if speaker.playNote == nil then
	print("(speaker on '" .. side .. "' has no playable interface)")
	return 0
end
local words = 0
for _ in text:gmatch("%S+") do words = words + 1 end
if words == 0 then return 0 end
for index = 1, words do
	speaker.playNote("bit", 1, 12 + (index % 12))
	sleep(0.1)
end
