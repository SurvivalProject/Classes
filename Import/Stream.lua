local Stream = {}

Stream.Palette = {g= Color3.new(0,1,0), y = Color3.new(1,1,0), 
pb = Color3.new(153/255,205/255,1), mr = Color3.new(1,50/255,80/255)}

Stream.DefaultColor = Color3.new(1,1,1)
Stream.Temporary = false

function Round(Num, Decimals)
	return math.floor((Num)*(10 ^Decimals) + 0.5)/(10^Decimals)
end

function Stream:GetColor(txt)
	local rstr = txt
	if type(txt) == "string" and txt:sub(1,1) == "_" then
		local cstr = txt:match("^_(%S*)")
		local rstr = txt:match("%s+(.*)")
		return (self.Palette[cstr] or self.DefaultColor), rstr
	else
		return self.DefaultColor, rstr
	end
end

Stream.Offset = 0

function Stream:ResetOffset()
	Stream.Offset = 0
end


function Stream:write(...)
	if not self.Data then 
		self.Data = {{"", Color3.new(1,1,1)}}
	end
	if not self.ConnectedConsole and self.Button then
		self.Button.BackgroundColor3 = Color3.new(1,85/255,127/255)
	end
	local arguments = {...}
	local color, first_text = self:GetColor(arguments[1])

	arguments[1] = first_text
	local new = {}
	self.Offset = 0
	for i,text in pairs(arguments) do
		if self.ConnectedConsole then
			self.ConnectedConsole:Write(text, color)
		end
		table.insert(new, {text, color})
	end
	for i,v in pairs(new) do
		table.insert(self.Data, v)
	end
end

function Stream:Show() 
	if System and System.Console then
		System.Console:StreamFocus(self)
		System.Console:Show(true)
	end
end

Stream.show = Stream.Show


function Stream:ParentChange(oldparent, newparent)
	OLDPRINT("CHANGE PARENT", newparent)
	if oldparent and  oldparent.ClassName == "StreamService" and oldparent ~= newparent then
		oldparent.StreamRemoved:fire(self)
	end
	if newparent and newparent.ClassName == "StreamService" and oldparent ~= newparent then
		newparent.StreamAdded:fire(self)
	end
end

Stream = CreateClass("Stream", Stream)

