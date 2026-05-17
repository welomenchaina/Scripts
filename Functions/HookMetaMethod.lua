local Module = {}

local hooks = {}
local blocked = {}
local lastArgs = {}

local function resolveRemote(remote)
	if typeof(remote) == "string" then
		local obj = game
		for part in string.gmatch(remote, "[^%.]+") do
			obj = obj:FindFirstChild(part)
			if not obj then
				return nil
			end
		end
		return obj
	end
	return remote
end

local mt = getrawmetatable(game)
local old = mt.__namecall

setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}

	if method == "FireServer" then
		if blocked[self] then
			return nil
		end

		local data = hooks[self]

		if data then
			for index,value in pairs(data.Args) do
				args[index] = value
			end

			lastArgs[self] = table.clone(args)

			return old(self, unpack(args))
		end
	end

	return old(self, ...)
end)

setreadonly(mt, true)

function Module.New(remote, replacements)
	remote = resolveRemote(remote)

	if not remote then
		return
	end

	hooks[remote] = {
		Args = replacements
	}
end

function Module.Block(remote)
	remote = resolveRemote(remote)

	if remote then
		blocked[remote] = true
	end
end

function Module.Resume(remote)
	remote = resolveRemote(remote)

	if remote then
		blocked[remote] = nil
	end
end

function Module.Unhook(remote)
	remote = resolveRemote(remote)

	if remote then
		hooks[remote] = nil
		lastArgs[remote] = nil
	end
end

function Module.CallLastArgs(remote)
	remote = resolveRemote(remote)

	if remote and lastArgs[remote] then
		remote:FireServer(unpack(lastArgs[remote]))
	end
end

return Module
