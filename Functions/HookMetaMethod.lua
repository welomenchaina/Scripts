local Module = {}

local hooks = {}
local blocked = {}

local mt = getrawmetatable(game)
local old = mt.__namecall

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	local args = {...}
	local method = getnamecallmethod()

	if method == "FireServer" then
		local data = hooks[self]

		if blocked[self] then
			return nil
		end

		if data then
			for i,v in pairs(data.Args) do
				args[i] = v
			end
			return old(self, unpack(args))
		end
	end

	return old(self, ...)
end)

setreadonly(mt, true)

function Module.New(remote, ...)
	hooks[remote] = {
		Args = {...}
	}
end

function Module.Block(remote)
	blocked[remote] = true
end

function Module.Resume(remote)
	blocked[remote] = nil
end

function Module.Unhook(remote)
	hooks[remote] = nil
end

return Module

--[[
HookMetaMethodModule Usage:
.New (Accepts remotes only, replaces specific arguments on call)
.Block (blocks a remote)
.Resume (resumes a blocked remote)
.Unhook (Unhooks a remote)
.Hook (hooks a property, currently only WalkSpped is supported, can be expanded to include more properties)
--]]

