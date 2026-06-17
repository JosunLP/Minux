-- seq: print a sequence of integers.
local args = { ... }
if args[1] == nil or args[1] == "?" or args[1] == "help" or args[1] == "--help" then
	print("Usage: seq [first [step]] last")
	print("Print integers from <first> (default 1) to <last>, stepping by <step>.")
	return 0
end

local first, step, last
if #args == 1 then
	first, step, last = 1, 1, tonumber(args[1])
elseif #args == 2 then
	first, step, last = tonumber(args[1]), 1, tonumber(args[2])
else
	first, step, last = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
end

if first == nil or step == nil or last == nil or step == 0 then
	print("seq: invalid numeric arguments")
	return false
end

local index = first
if step > 0 then
	while index <= last do print(index) index = index + step end
else
	while index >= last do print(index) index = index + step end
end
