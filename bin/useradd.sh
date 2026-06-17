-- useradd: add a user to the current auth system.
local args        = { ... }
local newusername = args[1]
local newpassword = args[2]

local function isHelpToken(token)
return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function withColor(color, callback)
if term.isColor() then term.setTextColor(color) end
callback()
if term.isColor() then term.setTextColor(colors.white) end
end

local function runUsermod(action, username, password)
local program, loadErr = loadfile("/bin/usermod.sh")
if program == nil then
withColor(colors.red, function()
print("useradd: cannot load user manager: " .. tostring(loadErr))
end)
return false
end
local ok, result = pcall(program, action, username, password)
if ok ~= true then
withColor(colors.red, function()
print("useradd: user creation failed: " .. tostring(result))
end)
return false
end
return result == true
end

if newusername ~= nil and isHelpToken(newusername) then
print("Usage: useradd <username> [password]")
print("       useradd help|-h|--help|?   show this message")
print("If no password is given, useradd prompts for one (input is masked).")
print("See 'man useradd' for details on local vs. network AUTH.")
return true
end

if newusername == nil or newusername == "" then
withColor(colors.red, function()
print("useradd: missing username")
end)
print("Usage: useradd <username> [password]")
return false
end

if newpassword == nil or newpassword == "" then
write("New password for " .. newusername .. ": ")
newpassword = read("*")
end
if newpassword == nil or newpassword == "" then
withColor(colors.red, function()
print("useradd: password must not be empty")
end)
return false
end

local authtype = minux.logintype()
if authtype == "disabled" then
withColor(colors.red, function()
print("useradd: no login system in use")
end)
print("Hint: enable one with 'config login local' or 'config login network'.")
return false
end

local ok
local printedByUsermod = false
if authtype == "network" then
if auth == nil or type(auth.useradd) ~= "function" then
withColor(colors.red, function()
print("useradd: network authentication tools are unavailable")
end)
print("Hint: 'apt -i auth-client' to install the network auth client.")
return false
end
ok = auth.useradd(newusername, newpassword) == true
elseif authtype == "local" then
ok = runUsermod("add", newusername, newpassword)
printedByUsermod = true
else
withColor(colors.red, function()
print("useradd: login type unknown or broken (" .. tostring(authtype) .. ")")
end)
return false
end

if ok ~= true then
return false
end
if printedByUsermod ~= true then
withColor(colors.lime, function()
print("useradd: created user '" .. newusername .. "'")
end)
end
return true
