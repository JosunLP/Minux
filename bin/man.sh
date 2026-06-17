-- man: display a manual page using the less viewer.
local args    = { ... }
local appname = args[1]

if appname == "list" then
shell.run("ls /etc/man/")
return 0
end

if appname == nil or appname == "" then
print("No topic given. Try 'man list'")
return false
end

local manpath = "/etc/man/" .. appname .. ".man"
if fs.exists(manpath) == false then
print("No manual for '" .. appname .. "'. Available pages:")
shell.run("ls /etc/man/")
return false
end

shell.run("/bin/less.sh", manpath)
