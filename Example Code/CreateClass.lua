-- This is an example class of "Fruit" and "Tree". It doesnt have anything to do with eventual editable food in-game. --

local Tree = {} -- Initialize a new empty class. It's just done via setting an empty table. This will later be pushed to the "CreateClass" function.

Tree.Fruit = SE_nil -- If we would set this to "nil" then the API dumper would not dump this. SE_nil is empty too (difference is: it's an object, so "if Tree.Fruit then" works..) but it makes sure it shows up in the API dump.

-- Take a note of this! 
-- Every time you are using the following Lua syntax:
-- some_object:some_function(some_arguments)
-- The only thing Lua does is REPLACING (well, I'm not sure if it really replaces, but you can threat it exactly like it!) it with this:
-- some_object.some_function(some_object, some_arguments)
-- "Yeah sure, I don't believe that."
-- Run this code in command bar: 
-- game.Destroy(game.Workspace.Part)
-- Is the same as
-- game.Workspace.Part:Destroy()
-- Also, when declaring methods:
-- function some_object:some_function(some_arguments)
-- blablabla
-- end
-- Is "replaced" by:
-- function some_object.some_function(self, some_arguments)
-- blabla
-- end
-- As you can see the first argument is called "self". That's why self always is the OBJECT you are calling it on! (you can also use "this")

function Tree:InitiateTree()
	self.Parent = System.TreeService -- I'll just call it "TreeService" as container for all trees.
	self.FruitList = {} -- Initialize a FruitList for the tree.
	self.Branches = math.random(4,7) -- Make 4-7 branches. On these branches we can spawn fruit.
	self.Fruit = Create("Apple") -- Create the Fruit. This is done because we want "random" fruit for every tree.
	self.Fruit:RandomType() -- And now randomize it. (Note that self.Fruit = Create("Apple"):Randomize() is also possible, does thes same)
	delay(0, function()
		while true do 
			repeat wait() until System.SeasonService.CurrentSeason == "Autumn" -- The fictional SE "service". I would rather use an event tough for this, due the wait() loop.
			wait(math.random(30,60)) -- Wait some time
			if #FruitList + 1 <= self.Branches then -- Check if we can spawn fruit. (The index represents the "branch", so this one always spawns on branch one first, then two, then three..)
				table.insert(self.FruitList, self.Fruit:Clone()) -- Insert a cloned fruit (this is done via :Clone as you can see) into the list
				-- NOTE
				-- for "memory optimalization" we could better create a kind of notification that food is there, instead of cloning the fruit. (true uses less memory than the complete fruit object!!)
				-- But how would we reach the same effect?? We could do it via metatables! We would have to declare FruitList as:
				--[[
						self.FruitList = {}
						local meta = {} 
						function meta.__index(source, index)
							if meta[index] then
								return self.Fruit
							else
								return nil
							end
						end
						function meta.__newindex(source, index, value)
							table.insert(meta, value)
						end
						setmetatable(self.FruitList, meta)
						-- Code for creating fruit;
						self.FruitList[1] = true -- We can always use the first index, as the metatable will handle placing that fruit. (via newindex)
						-- Code for getting fruit is just normally;
						print(self.FruitList[2]) -- Should return the fruit on the second branch. Note that this does not return true or nil, but the actual fruit object!!
						-- For even better organization we should use one metatable for every object, instead of new metatables for every object.
				--]]			
			end
		end
	end)
end

function Tree:Constructor() -- Every time "Create("Tree")" is called, the Constructor function will run IF PRESENT.
	-- In this case we need to setup a  "build" fruit drop routine.
	-- I'll be using a fictional SE API function.
	self:InitiateTree() -- Just redirecting to InitiateTree, it feels better.
end

local Fruit = {} -- Initialize an empty "class"

Fruit.Color = "Red" -- Just a dummy variable.
Fruit.VitaminA = 1 -- Another dummy.
Fruit.VitaminB = 0 -- And another one.

-- Note that above values are always returned as "standard". If it's not set in either
-- the derived class OR the object, it will return this value! (This is called inheritance!)

Fruit.NutritionValue = 125 -- Another dummy

function Fruit:Eat(Ammount) -- An "eat" function.
	self.NutritionValue = self.NutritionValue - Ammount -- Take some NutritionValue away.
	print("Yummy!!")
	if self.NutritionValue <= 0 then
		self:Destroy() -- Actual SE function. This isn't roblox.
		-- And also note that it can go negative.
	end 
end


local Apple = {} -- A new class. This one will extend Fruit.

Apple.Extends = Fruit -- This is necessary as it will tell the class creator to "extend" fruit.
-- What does that practically mean? 
-- It means that EVERY PROPERTY / EVENT / FUNCTION can be accessed from this class.

function Apple:FixColor() -- Because all apples are green, of course :)
	self.Color = "Green"
end

function Apple:Constructor()
	self:FixColor()
	self.NutritionValue = self.NutritionValue * (1 + math.random()) -- More nutrition!!
end

local AppleTypes = {"Green apple", "Normal apple"} -- This will be an enum. We will create it here:
SE_Enum.make("AppleTypes", AppleTypes) -- Create an enum. The actual enums will be stored as SE_Enum[Enum_Name] = {Enum1 = enum, Enum2 = enum} (not SE_Enum[Enum_Name] = {Enum1, Enum2})
-- Now we can set values to SE_Enum.AppleTypes["Green apple"] for example.

Apple.Type = SE_Enum.AppleTypes["Green apple"] -- So, you can run "if Apple.Type == SE_Enum.AppleTypes["Green apple"]" There is no support for equalling it to a string. That will come.

function Apple:RandomType()
	self.Type = SE_Enum.AppleTypes:Random() -- enum function to return a random enum of a certain type
end

CreateClass("Tree", Tree) -- Finally, register the classes. These classes are normally made in a "local environment". That means you cannot access the class directly (to prevent people destroying classes or base functions in an effective way). You can create objects tough which are free to edit.
CreateClass("Fruit", Fruit)
CreateClass("Apple", Apple)

-- CreateClass(classname, class)

-- IN ANOTHER SCRIPT TO CREATE A "Create tree and wait until fruit spawns and then eat it " SCRIPT
-- This will run as the above code will all be imported
local tree =  Create("Tree") -- Create a new "Tree" object. This is an object, not a class!!

repeat wait() until tree.FruitList and #tree.FruitList >= 1 --It would be better to connect an event. tree.FruitSpawned:connect(function(fruit) fruit:Eat() end)

tree.FruitList[1]:Eat() -- Yummeh



