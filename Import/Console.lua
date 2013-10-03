Console = CreateClass("Console", {})

local o = Console

-- WHEN LIBRARY IS DONE THIS HAS TO BE MOVED TO Libs.TextUtils--
function TextLen(text, size)
	local a = Instance.new("TextLabel", game.Players.LocalPlayer.PlayerGui:GetChildren()[1])
	a.FontSize = size
	a.Text = text
	return a.TextBounds
end

function Round(Num, Decimals)
	return math.floor((Num)*(10 ^Decimals) + 0.5)/(10^Decimals)
end

Console.AttachedStreams = {}
Console.StreamTabOffset = 10
Console.TextSize = 14
Console.LastFocus = nil
Console.CurrentFocus = nil
Console.ShowTabsAlways = true

function Console:Init()
	repeat wait() until game.Players.LocalPlayer.Character
	repeat wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	if script.className == "LocalScript" then
		self.DidInit = true
		local Gui = game.Lighting.GUIs.Console:Clone()
		Gui.Parent = game.Players.LocalPlayer.PlayerGui
		print("gui", game.Players.LocalPlayer.Name)
		self.Gui = Gui
		self.SampleText = self.Gui.Screen.SampleText
		self.SampleTab = self.Gui.SampleTab
		self.SampleText.Parent = nil
		self.SampleTab.Parent = nil
		self:Show(false)
		self.Gui.Input.InputBox.Changed:connect(function() self:ExecuteCommand() end)
		self.Gui.Screen.MouseWheelForward:connect(function()
			if self.CurrentFocus then
				self.CurrentFocus.Offset = self.CurrentFocus.Offset - 1				
				if self.CurrentFocus.Offset < 0 then
					self.CurrentFocus.Offset = 0
				end
				self:Flush()
				self:Update(self.CurrentFocus)
			end
		end)
		self.Gui.Screen.MouseWheelBackward:connect(function()
			if self.CurrentFocus then
				self.CurrentFocus.Offset = self.CurrentFocus.Offset + 1
				local max = math.ceil((self.Gui.Screen.AbsoluteSize.y - self.TextSize + 2) / (self.TextSize-2))
				if self.CurrentFocus.Offset > #self.CurrentFocus.Data - max - 1 then
					self.CurrentFocus.Offset = #self.CurrentFocus.Data - max - 1
				end
				self:Flush()
				self:Update(self.CurrentFocus)
			end
		end)
	else
		printstream("Internal Error", "Cannot build GUI on server")
	end
end

function Console:Show(bool)
	if not self.DidInit or not game.Players.LocalPlayer.PlayerGui:FindFirstChild("Console") then
		wait()
		self:Init()
	end 
	for i,v in pairs(game.Players.LocalPlayer.PlayerGui.Console:GetChildren()) do
		if v:IsA("Frame") then
			v.Visible = bool
		else
			v.Visible = Console.ShowTabsAlways
		end
	end
end

function Console:Push()
	for index, value in pairs(self.Gui.Screen:GetChildren()) do
		if value.Name == "StreamText" then
			value.Position = UDim2.new(value.Position.X.Scale, value.Position.X.Offset, value.Position.Y.Scale, value.Position.Y.Offset - self.TextSize + 2)
			if value.AbsolutePosition.Y < 10 then 
				value:Destroy()
				Done = true
			end
		end
	end
	return Done
end

function Console:Write(Text, Color)
	-- ADD PALLETTE FUNCTIONS!!!!!
	local Done = self:Push()
	local Clone = self.SampleText:Clone()
	Clone.Text = Text
	Clone.TextColor3 = Color or Color3.new(1,1,1)
	Clone.FontSize = Enum.FontSize["Size"..self.TextSize]
	Clone.Parent = self.Gui.Screen	
	Clone.Name = "StreamText"
	return Done
end

function Console:Flush()
	for index, value in pairs(self.Gui.Screen:GetChildren()) do
		if value.Name == "StreamText" then
			value:Destroy()
		end
	end
end

function Console:Update(Stream)
	local Data = Stream.Data
	local max = math.ceil((self.Gui.Screen.AbsoluteSize.y - self.TextSize - 8) / (self.TextSize-2))
	if Data then 
	local ndata = #Data
	local num = ndata - Stream.Offset - max
	local numend = ndata - Stream.Offset
	if numend > ndata then
		num = ndata - max 
		numend = ndata
	end
	if num < 1 then
		num = 1
		numend = 1 + max
	end
	for i = num,  numend do 
		if Data[i] then
			local text = Data[i]
			self:Write(text[1], text[2])			
		end
	end	
	end
end

function Console:StreamFocus(Stream)
	self:Flush()
	Stream:ResetOffset()
	if self.CurrentFocus then 
	self.CurrentFocus.ConnectedConsole = nil
		if self.CurrentFocus.Temporary then 
			self.CurrentFocus:Destroy()
		end
	end
	self.CurrentFocus = Stream
	Stream.ConnectedConsole = self
	self:Update(Stream)
end


function Console:AddStreamTab(Stream)
	local Name = (Stream.Temporary and ("[T] "..Stream.Name)) or Stream.Name
	local Length = TextLen(Name, Enum.FontSize.Size14).X
	local Bonus = 10
	local Clone = self.SampleTab:Clone()
	Clone.Text = Name	
	Clone.Size = UDim2.new(0, Length + Bonus, 0, 14)
	Clone.Position = UDim2.new(0, self.StreamTabOffset, 1, -100)
	if Stream.Temporary then
		Clone.BackgroundColor3 = Color3.new(1,1,127/255)
	end
	Clone.Parent = self.Gui
	Stream.Button = Clone
	self.StreamTabOffset = self.StreamTabOffset + Bonus + Length
	table.insert(self.AttachedStreams, {Stream, Clone})
	Clone.MouseButton1Click:connect(function()
		Stream.Button.BackgroundColor3 = Color3.new(85/255,1,127/255)
		Stream.Offset = 0
		self:StreamFocus(Stream)
		self:Show(true)
	end)
end

function Console:RemoveStreamTab(Stream)
	for i,v in pairs(self.AttachedStreams) do 
		if v[1] == Stream then
			local osize = v[2].Size.X.Offset
			v[2]:Destroy()
			local temp = v[1]
			table.remove(self.AttachedStreams, i)
				for ind = i, #self.AttachedStreams do 
					local other = self.AttachedStreams[ind][2]
					OLDPRINT(other)
					other:TweenPosition(UDim2.new(other.Position.X.Scale, other.Position.X.Offset - osize, other.Position.Y.Scale, other.Position.Y.Offset))
				end
			break
		end
	end

end	

Console.Commands = {
exit = function(self) self:Show(false) end,
help = function(self)
	for i,v in pairs(self.Commands) do
		self.ConsoleStream:write(i)
	end
end,
resman = function(self)
end,
send = function(self, msg)
	local to, message = msg:match("send (%w+) (.+)")
	if to and message then
		System.MessageCentral:OutgoingMessage(to,message)
	else
		self.ConsoleStream:write("syntaxis is: send <playername> <message>")
	end	
end
}

Console.Last = "_"

function Console:ExecuteCommand()
	self:StreamFocus(self.ConsoleStream)
	local command = self.Gui.Input.InputBox.Text
	if command ~= self.Last and command ~= "_" then
		self.Last = command
		self.ConsoleStream:write("> "..command)
		local real_command = command;
		for comname, comfunc in pairs(self.Commands) do
			if command:match("^" ..comname) then 
				comfunc(self, command)
				return
			end
		end
		self.ConsoleStream:write(command.." is not a valid SE function, tool or item.")		
	end
end
	

Console = Create("Console")

o.Uncreatable = true

System.StreamService.StreamAdded:connect(function(Stream) 
	Console:AddStreamTab(Stream)
end)

System.StreamService.StreamRemoved:connect(function(Stream)
	Console:RemoveStreamTab(Stream)
end)

Console.Name = "Console"

Console.Parent = System

Console:Init()

-- Start making default streams [also to immediately flush buffers] --

local ConsoleStream = Create("Stream")
ConsoleStream.Name = "Console"
ConsoleStream.Parent = System.StreamService

Console.ConsoleStream = ConsoleStream
ConsoleStream:write("SE command line for ".._SE_VERSION..": ")

local InternInfoStream = Create("Stream")
InternInfoStream.Name = "Internal Info"
InternInfoStream.Parent = System.StreamService

local InternErrorStream = Create("Stream")
InternErrorStream.Name = "Internal Error"
InternErrorStream.Parent = System.StreamService

InternWarningStream = Create("Stream")
InternWarningStream.Name = "Internal Warning"
InternWarningStream.Parent = System.StreamService
-- Run this when getting the 32 (CONSOLE_INIT_ERROR) error or the intern system event 8 (TASK_KILL_TOSLOW)
-- System:ntfy(443)
-- System:try_init(SE_SYSTEM_EVENT_BUFFER[2] or SE_SYSTEM_EVENTS["CLIB MOVE"])
-- System:mov(clib, clibpsd2)