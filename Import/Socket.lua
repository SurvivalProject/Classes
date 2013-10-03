local Socket = {} 

local SocketRoot = game.Players.LocalPlayer:FindFirstChild("Sockets") or Instance.new("Model", game.Players.LocalPlayer)
SocketRoot.Name = "Sockets"
local Sockets = 0

function Socket:Put(msg)
	local destination = self.Receiver.Parent and self.Receiver:FindFirstChild("Sockets") 
	if not destination then
		printstream("Internal Error", "Error putting "..msg.. " to "..self.Receiver.Name)
		return false
	end
	local destination =	self.Receiver.Sockets:FindFirstChild(game.Players.LocalPlayer.Name)
	if not destination then
		local mod = Instance.new("Model", self.Receiver.Sockets)
		mod.Name = game.Players.LocalPlayer.Name
	end
	local str = Instance.new("StringValue")
	str.Value = msg
	str.Parent = destination
	return true	
end

function Socket:Close()
	self:Put("close")
	self:Destroy()
end

Socket.Receiver = SE_nil

function Socket:Constructor() 
	Sockets = Sockets+1
	local new_socket_bin = Instance.new("Model", SocketRoot)
	new_socket_bin.Name = "Socket"..Sockets
	self.SocketRoot = new_socket_bin
end

function Socket:Wait()
	local added = self.SocketRoot.ChildAdded:wait()
	return added
end

function Socket:WaitFor(msg)
	local last = {}
	repeat 		
		last = self:Wait()		
	until last == msg
end

function Socket:InitiateChat()
	local write_stream = System.StreamService:TemporaryStream(">"..self.Receiver)
	while true do
		local msg = self:Wait()
		if msg == "close" then
			self:Put("bye")
			write_stream:write("_r "..self.Receiver.Name.." closed connection")
			return
		end
		write_stream:write(msg)
	end
end
		

function Socket:SetReceiver(r)
	self.Receiver = r
	self.SocketRoot.Name = r.Name
	self:Put("hello "..r.Name .. " from ".. game.Players.LocalPlayer.Name)
	delay(0, function()
	local msg = self:Wait()
	self:InitiateChat() 
	end)
end

