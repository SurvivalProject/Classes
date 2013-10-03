local KeyService = {}

KeyService.Keys = {}

local fix = {}
fix.__index = function(tab, index)
	rawset(tab, index, {false, tick()})
	return rawget(tab, index)
end

setmetatable(KeyService.Keys, fix) -- Fixes a "nil-call" when key was not down / up yet

function KeyService:GetKey(input)
	return (type(input) == "number" and input) or (type(input) == "string" and input:byte()) or 1
end

function KeyService:KeyIsUp(key)
	return self.Keys[self:GetKey(key)][1] and true 
end

function KeyService:KeyIsDown(key)
	return not self:KeyIsUp(key)
end

function KeyService:GetTime(key)
	return tick() - self.Keys[key][2]
end

function KeyService:KeyIsDownFor(key, time)
	return self:KeyIsDown(key) and self:GetTime(key) > time
end

function KeyService:KeyIsUpFor(key, time)
	return self:KeyIsUp(key) and self:GetTime(key) > time
end

function KeyService:Initiate() 
local mouse = game.Players.LocalPlayer:GetMouse() 
mouse.KeyUp:connect(function(key) 
	self.Keys[key:byte()] = {true, tick()}
end)
mouse.KeyDown:connect(function(key)
	self.Keys[key:byte()] = {false, tick()}
end)
end

KeyService = CreateClass("KeyService", KeyService)

KeyServ = Create("KeyService")

KeyServ.Name = "KeyService"
KeyService.Uncreatable = true
KeyServ.Parent = System

print("KeyService needs events")
