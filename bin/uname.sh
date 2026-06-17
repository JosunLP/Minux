-- uname: print system information (ReMinux version, kernel, host).
local args = { ... }
local flag = args[1]

local kernel  = "CC: Tweaked"
if _HOST ~= nil then kernel = _HOST end
local version = _G.version or "Unknown"
local cid     = tostring(os.getComputerID())
local label   = os.getComputerLabel() or ("computer-" .. cid)
local arch    = "lua-" .. (_VERSION or "5.1")
local kind    = "computer"
if turtle ~= nil then kind = "turtle" end
if pocket ~= nil then kind = "pocket" end
if commands ~= nil then kind = "command-computer" end

local function printAll()
	print("ReMinux " .. version .. " (" .. kind .. ")")
	print("Kernel : " .. kernel)
	print("Host   : " .. label .. " (id " .. cid .. ")")
	print("Arch   : " .. arch)
end

if flag == "?" or flag == "help" or flag == "-h" or flag == "--help" then
	print("Usage: uname [-a|-s|-r|-n|-m]")
	print("  -a  all (default)")
	print("  -s  kernel/system name")
	print("  -r  ReMinux release/version")
	print("  -n  computer label")
	print("  -m  Lua/architecture")
elseif flag == "-s" then print(kernel)
elseif flag == "-r" then print(version)
elseif flag == "-n" then print(label)
elseif flag == "-m" then print(arch)
else
	printAll()
end
