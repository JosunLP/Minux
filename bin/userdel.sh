-- userdel: remove a user from the current auth system.
local args = { ... }

local function isHelpToken(token)
return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function withColor(color, callback)
if term.isColor() then term.setTextColor(color) end
callback()
if term.isColor() then term.setTextColor(colors.white) end
end

-- Parse args: support an optional `-y` / `--yes` flag in any position.
local newusername
local skipConfirm = false
for _, arg in ipairs(args) do
if arg == "-y" or arg == "--yes" then
skipConfirm = true
elseif newusername == nil then
newusername = arg
end
end

local function runUsermod(action, username)
local program, loadErr = loadfile("/bin/usermod.sh")
if program == nil then
withColor(colors.red, function()
print("userdel: cannot load user manager: " .. tostring(loadErr))
end)
return false
end
local ok, result = pcall(program, action, username)
if ok ~= true then
withColor(colors.red, function()
print("userdel: user deletion failed: " .. tostring(result))
end)
return false
end
return result == true
end

if newusername ~= nil and isHelpToken(newusername) then
print("Usage: userdel <username> [-y]")
print("       userdel help|-h|--help|?   show this message")
print("Use -y or --yes to skip the confirmation prompt.")
print("See 'man userdel' for AUTH backend specifics.")
return true
end

if newusername == nil or newusername == "" then
withColor(colors.red, function()
print("userdel: missing username")
end)
print("Usage: userdel <username> [-y]")
return false
end

local authtype = minux.logintype()
if authtype == "disabled" then
withColor(colors.red, function()
print("userdel: no login system in use")
end)
return false
end

if skipConfirm ~= true then
write("Delete user '" .. newusername .. "'? [y/N]: ")
local answer = read()
if answer == nil then answer = "" end
answer = string.lower(answer)
if answer ~= "y" and answer ~= "yes" then
print("userdel: aborted")
return false
end
end

local ok
local printedByUsermod = false
if authtype == "network" then
if auth == nil or type(auth.userdel) ~= "function" then
withColor(colors.red, function()
print("userdel: network authentication tools are unavailable")
end)
print("Hint: 'apt -i auth-client' to install the network auth client.")
return false
end
ok = auth.userdel(newusername) == true
elseif authtype == "local" then
ok = runUsermod("del", newusername)
printedByUsermod = true
else
withColor(colors.red, function()
print("userdel: login type unknown or broken (" .. tostring(authtype) .. ")")
end)
return false
end

if ok ~= true then
return false
end
if printedByUsermod ~= true then
withColor(colors.lime, function()
print("userdel: removed user '" .. newusername .. "'")
end)
end
return true
