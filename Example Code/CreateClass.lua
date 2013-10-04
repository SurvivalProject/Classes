-- This is an example class of "Fruit" and "Tree". It doesnt have anything to do with eventual editable food in-game. --

local Tree = {}

Tree.Fruit = Create("Fruit")

function Tree:InitiateTree()
self.Parent = System.TreeService -- I'll just call it "TreeService" as container for all trees.
self.FruitList = {}
self.Branches = math.random(4,7)
self.Fruit = Create("Apple")
self.Fruit:RandomType()
delay(0, function()
while true do
repeat wait() until System.SeasonService.CurrentSeason == "Autumn" -- The fictional SE "service". I would rather use an event tough for this, due the wait() loop.
wait(math.random(30,60))
if #FruitList + 1 <= self.Branches then
table.insert(self.FruitList, self.Fruit:Clone())
-- Inserts the cloned "tree food" into the fruit list. It is now accessible for others, for example to create the actual Fruit object brick or to eat it!
end
end
end)
end

function Tree:Constructor() -- Every time "Create("Tree")" is called, the Constructor function will run IF PRESENT.
-- In this case we need to setup a  "build" fruit drop routine.
-- I'll be using a fictional SE API function.
self:InitiateTree()
end

local Fruit = {} -- Initialize an empty "class"

Fruit.Color = "Red" -- Just a dummy variable.
Fruit.VitaminA = 1 -- Another dummy.
Fruit.VitaminB = 0 -- And another one.

-- Note that above values are always returned as "standard". If it's not set in either
-- the derived class OR the object, it will return this value! (This is called inheritance!)

Fruit.NutritionValue = 125 -- Another dummy

function Fruit:Eat(Ammount) -- An "eat" function.
self.NutritionValue = self.NutritionValue - Ammount
print("Yummy!!")
if self.NutritionValue <= 0 then
self:Destroy() -- Actual SE function. This isn't roblox.
end 
end


local Apple = {} -- A new class. This one will extend Fruit.

Apple.Extends = Fruit -- This is necessary as it will tell the class creator to "extend" fruit.
-- What does that practically mean? 
-- It means that EVERY PROPERTY / EVENT / FUNCTION can be accessed from this class.

function Apple:FixColor()
self.Color = "Green"
end

function Apple:Constructor()
self:FixColor()
self.NutritionValue = self.NutritionValue * (1 + math.random())
end

local AppleTypes = {"Green apple", "Normal apple"} -- This will be an enum. We will create it here:
SE_Enum.make("AppleTypes", AppleTypes)
-- Now we can set values to SE_Enum.AppleTypes["Green apple"] for example.

Apple.Type = SE_Enum.AppleTypes["Green apple"]

function Apple:RandomType()
self.Type = SE_Enum.AppleTypes:Random() -- enum function to return a random enum of a certain type
end

CreateClass("Tree", Tree)
CreateClass("Fruit", Fruit)
CreateClass("Apple", Apple)

-- IN ANOTHER SCRIPT TO CREATE A "Create tree and wait until fruit spawns and then eat it " SCRIPT

local tree =  Create("Tree")

repeat wait() until tree.FruitList and #tree.FruitList >= 1

tree.FruitList[1]:Eat() -- This is a fruit



