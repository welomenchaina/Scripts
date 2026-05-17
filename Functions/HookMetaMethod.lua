local HookMetaMethodModule = {}

local blockedRemotes = {}
local hookedRemotes = {}
local lastArgs = {}
local resumedRemotes = {}

local function resolveRemote(remote)
	if typeof(remote) == "string" then
		local obj = game
		for part in string.gmatch(remote, "[^%.]+") do
			obj = obj:FindFirstChild(part)
			if not obj then return nil end
		end
		return obj
	end
	return remote
end

function HookMetaMethodModule.New(remote, ...)
	remote = resolveRemote(remote)
	if not remote or typeof(remote) ~= "Instance" then return end
	if hookedRemotes[remote] then return end
	local args = {...}
	local oldFireServer
	oldFireServer = hookfunction(remote.FireServer, function(self, ...)
		if blockedRemotes[self] then return end
		local callArgs = table.pack(...)
		for i, v in ipairs(args) do
			callArgs[i] = v
		end
		lastArgs[self] = callArgs
		return oldFireServer(self, table.unpack(callArgs, 1, callArgs.n))
	end)
	hookedRemotes[remote] = oldFireServer
end

function HookMetaMethodModule.Block(remote)
	remote = resolveRemote(remote)
	if remote then
		blockedRemotes[remote] = true
	end
end

function HookMetaMethodModule.Resume(remote)
	remote = resolveRemote(remote)
	if remote then
		blockedRemotes[remote] = nil
		resumedRemotes[remote] = true
	end
end

function HookMetaMethodModule.Unhook(remote)
	remote = resolveRemote(remote)
	if remote and hookedRemotes[remote] then
		local old = hookedRemotes[remote]
		hookfunction(remote.FireServer, old)
		hookedRemotes[remote] = nil
		lastArgs[remote] = nil
	end
end

function HookMetaMethodModule.CallLastArgs(remote)
	remote = resolveRemote(remote)
	if remote and lastArgs[remote] and not blockedRemotes[remote] then
		remote:FireServer(table.unpack(lastArgs[remote], 1, lastArgs[remote].n))
	end
end

function HookMetaMethodModule.Hook(property)
	if not property then return end
	property = tostring(property)
	if property:lower() == "walkspeed" then
		local mt = getrawmetatable(game.Players.LocalPlayer)
		local old = mt.__newindex
		setreadonly(mt, false)
		mt.__newindex = function(self, k, v)
			if k:lower() == "walkspeed" then
			end
			return old(self, k, v)
		end
		setreadonly(mt, true)
	end
end

return HookMetaMethodModule

--[[
HookMetaMethodModule Usage:
.New (Accepts remotes only, replaces specific arguments on call)
.Block (blocks a remote)
.Resume (resumes a blocked remote)
.Unhook (Unhooks a remote)
.Hook (hooks a property, currently only WalkSpped is supported, can be expanded to include more properties)
--]]

