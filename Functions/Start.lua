local Setup = {}
local player = game:GetService("Players").LocalPlayer
local function getHumanoid()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChildOfClass("Humanoid")
end

function Setup.Load()
	repeat task.wait() until game:IsLoaded()
end

function Setup.LoadSemiBypass()
	if setfflag then pcall(setfflag, "AbuseReportScreenshotPercentage", "0") end
	if setfflag then pcall(setfflag, "AbuseReportScreenshot", "False") end
	if hookfunction and player then
		hookfunction(player.Kick, function() end)
		local mt = getrawmetatable(game)
		local old = mt.__namecall
		setreadonly(mt, false)
		mt.__namecall = function(self, ...)
			if getnamecallmethod and getnamecallmethod() == "Kick" and self == player then
				return
			end
			return old(self, ...)
		end
		setreadonly(mt, true)
	end
end

function Setup.Freeze()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hum.AutoRotate = false
	end
end

function Setup.Thaw()
	local hum = getHumanoid()
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		hum.AutoRotate = true
	end
end

function Setup.HookFunctions()
	local t = {}
	t.getnamecallmethod = typeof(getnamecallmethod) == "function"
	t.hookfunction = typeof(hookfunction) == "function"
	t.getrawmetatable = typeof(getrawmetatable) == "function"
	t.setreadonly = typeof(setreadonly) == "function"
	t.pcall = typeof(pcall) == "function"
	t.isfile = typeof(isfile) == "function"
	t.readfile = typeof(readfile) == "function"
	t.writefile = typeof(writefile) == "function"
	return t
end

function Setup.BetterFileFunctions()
	local r = {}
	local function try(fn, ...)
		local ok, val = pcall(fn, ...)
		return ok and val or nil
	end
	r.isfile = function(p)
		return try(isfile, p) and true or false
	end
	r.readfile = function(p)
		if r.isfile(p) then
			return try(readfile, p)
		end
		return nil
	end
	r.writefile = function(p, d)
		return try(writefile, p, d)
	end
	r.delfile = function(p)
		return try(delfile, p)
	end
	return r
end

return Setup
