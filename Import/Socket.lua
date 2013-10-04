local Socket = {} 

local SocketRoot = game.Players.LocalPlayer:FindFirstChild("Sockets") or Instance.new("Model", game.Players.LocalPlayer)
SocketRoot.Name = "Sockets"

function Socket:Put(msg)
	local destination = self.Receiver.Parent and self.Receiver:FindFirstChild("Sockets") 
	if not destination then
		printstream("Internal Error", "Error putting "..msg.. " to "..self.Receiver.Name)
		return false
	end
	local destination =	self.Receiver.Sockets:FindFirstChild(game.Players.LocalPlayer.Name)
	if not destination then
		local mod = Instance.new("Model")
		mod.Name = game.Players.LocalPlayer.Name
		mod.Parent = self.Receiver.Sockets
		self.SocketRoot = mod
	end
	local destination =destination or self.Receiver.Sockets:FindFirstChild(game.Players.LocalPlayer.Name)
	self.SocketRoot = destination
	local str = Instance.new("StringValue")
	str.Value = msg
	str.Parent = destination
	print("Destination:: "..str.Parent.Parent.Parent.Name)
	return true	
end

function Socket:Close()
	self:Put("close")
	self:Destroy()
end

Socket.Receiver = SE_nil

function Socket:Wait()
	print(self.SocketRoot:GetFullName())
	local added = self.SocketRoot.ChildAdded:wait()
	print(added)
	return added
end

function Socket:WaitFor(msg)
	local last = {}
	repeat 		
		last = self:Wait()		
	until last == msg
end

function Socket:InitiateChat()
	local write_stream = System.StreamService[">"..self.Receiver.Name] or Create("Stream", System.StreamService)
	write_stream.Name = ">"..self.Receiver.Name
	write_stream:write("socket service started at "..math.floor(tick()+0.5).."!")
	while true do
		local msg = self:Wait().Value
		if msg == "close" then
			self:Put("bye")
			write_stream:write("_r "..self.Receiver.Name.." closed connection")
			return
		end
		if type(msg) == "string" then
			write_stream:write(msg)
		end
	end
end
		

function Socket:SetReceiver(r, direction) -- Direction false = out; true = in
	self.Receiver = r
	if not direction then 
		self:Put("hello "..r.Name .. " from ".. game.Players.LocalPlayer.Name)
		System.MessageCentral:Register(self, r.Name)
	else
		delay(0, function()
			self:InitiateChat() 
		end)
	end
end

CreateClass("Socket", Socket)
