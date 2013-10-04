local MessageCentral = {}

local SocketRoot = game.Players.LocalPlayer:FindFirstChild("Sockets") or Instance.new("Model", game.Players.LocalPlayer)
SocketRoot.Name = "Sockets"

function MessageCentral:OutgoingMessage(to, msg)
	print(to, msg)
	if to and msg and self.List[to] then
		self.List[to]:Put(msg)
	end
end

MessageCentral.List = {}

function MessageCentral:Register(what, name)
	print(what:IsA("Socket"), "Is Socket?", name)
	if what:IsA("Socket") then 
		self.List[name] = what
	end
end

function MessageCentral:Constructor()

SocketRoot.ChildAdded:connect(function(what)
	print("New socket added, user: "..what.Name.." direction is IN")
	local sender = what.Name
	local socket = Create("Socket")
	socket.SocketRoot = what
	socket:SetReceiver(game.Players[what.Name], true)
end)

end

CreateClass("MessageCentral", MessageCentral)
local MC = Create("MessageCentral", System)
MC.Name = "MessageCentral"