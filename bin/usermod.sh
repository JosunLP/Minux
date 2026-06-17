-- user management tool (local auth only)
local args = { ... }
local action   = args[1]
local username = args[2]
local newpass  = args[3]

local function withColor(color, callback)
if term.isColor() then term.setTextColor(color) end
callback()
if term.isColor() then term.setTextColor(colors.white) end
end

local function isHelpToken(token)
return token == "help" or token == "-h" or token == "--help" or token == "?"
end

local function err(message)
withColor(colors.red, function()
print("usermod: " .. message)
end)
end

local function ok(message)
withColor(colors.lime, function()
print("usermod: " .. message)
end)
end

local function printGeneralUsage()
print("Usage: usermod <action> <username> [password]")
print("       usermod help|-h|--help|?   show this message")
print("Actions: add, del, psw")
end

if _G.admin ~= true then
err("requires admin privileges")
print("Hint: log in as an admin or owner before changing users.")
return false
end

if fs.exists("/usr/minux-main/settings.cfg") == false then
err("configuration files are missing")
print("Hint: run 'config login local' to restore local auth settings.")
return false
end

local authtype = minux.getconfig("login")
if authtype ~= "local" then
err("local auth is disabled (login=" .. tostring(authtype) .. ")")
print("Use 'auth-client' to manage networked users.")
print("Hint: install it with 'apt -i auth-client' if needed.")
return false
end

-- Read the encryption key from disk; returns nil when encryption is off.
local function readEncryptKey()
local keyPath = "/usr/minux-main/config/encr.conf"
if fs.exists(keyPath) then
local keyfile = fs.open(keyPath, "r")
local key = tonumber(keyfile.readLine())
keyfile.close()
return key
end
return nil
end

-- Write a password to a user file, encrypting it when applicable.
local function writeUserFile(path, password)
local key = readEncryptKey()
if key ~= nil then
password = minux.encrypt(password, key)
end
if fs.exists("/usr/local/auth/") == false then
fs.makeDir("/usr/local/auth/")
end
local file = fs.open(path, "w")
if file == nil then
return false
end
file.write(password)
file.close()
return fs.exists(path)
end

local userPath = "/usr/local/auth/" .. (username or "") .. ".usr"

if isHelpToken(action) then
print("usermod - local user management")
printGeneralUsage()
print("  add  <username> <password>  - create a new user")
print("  del  <username>             - delete a user")
print("  psw  <username> <password>  - reset a user's password")
return true

elseif action == nil or action == "" then
err("missing action")
printGeneralUsage()
return false

elseif action == "add" then
if username == nil or newpass == nil then
err("missing username or password for 'add'")
print("Usage: usermod add <username> <password>")
return false
end
local validUser, userError = minux.validateUsername(username)
if validUser ~= true then
err("invalid username '" .. tostring(username) .. "': " .. tostring(userError))
return false
end
if newpass == "" then
err("password must not be empty")
return false
end
if fs.exists(userPath) then
err("user already exists: " .. username)
return false
end
if writeUserFile(userPath, newpass) ~= true then
err("could not write user file")
return false
end
ok("added user '" .. username .. "'")
return true

elseif action == "del" then
if username == nil then
err("missing username for 'del'")
print("Usage: usermod del <username>")
return false
end
local validUser, userError = minux.validateUsername(username)
if validUser ~= true then
err("invalid username '" .. tostring(username) .. "': " .. tostring(userError))
return false
end
if fs.exists(userPath) == false then
err("user does not exist: " .. username)
return false
end
if username == "root" then
err("cannot delete the root user")
return false
end
if _G.login ~= nil and username == _G.login then
err("cannot delete your own account")
return false
end
fs.delete(userPath)
if fs.exists(userPath) == true then
err("could not remove user file")
return false
end
ok("removed user '" .. username .. "'")
return true

elseif action == "psw" then
if username == nil or newpass == nil then
err("missing username or password for 'psw'")
print("Usage: usermod psw <username> <password>")
return false
end
local validUser, userError = minux.validateUsername(username)
if validUser ~= true then
err("invalid username '" .. tostring(username) .. "': " .. tostring(userError))
return false
end
if newpass == "" then
err("password must not be empty")
return false
end
if fs.exists(userPath) == false then
err("user does not exist: " .. username)
return false
end
if writeUserFile(userPath, newpass) ~= true then
err("could not write user file")
return false
end
ok("updated password for '" .. username .. "'")
return true

else
err("unknown action '" .. tostring(action) .. "'")
printGeneralUsage()
return false
end
