local Sine = {}

Sine.Types = {}

local SineMeta = {}

SineMeta.__index = function(Source, Index)
	return SineMeta.Types[Index] or rawget(Sine, Index)
end

SineMeta.__newindex = function(Source, Index, Value)
	if Index == "LastCall" or Index == "Derivative" then
		rawset(Source, Index, Value)
	end
end

SineMeta.Types = {Cosine = {}, Sine = {}}

setmetatable(Sine.Types, SineMeta)

SineMeta.__call = function(self, x, update)
	local x = x or 0
	if self == Sine then return end
	if not update then
	self.LastCall = x
	end
	return self.a + self.b *  math.sin(self.c * ( x - self.d ))
end

function Sine.new(max, min, period, start, type)
		local o = {}
		o.a = (max + min) / 2
		o.b =  max - o.a
		o.c = (2 * math.pi) / period
		o.d = ((type == Sine.Types.Cosine) and (start + period / 4)) or start
		setmetatable(o, SineMeta)
		return o
end

function Sine:GetNextMiddlePoint(x)
	local Last = x or self.LastCall or 0
	-- SOLVE: a + b sin(c(x-d)) = self.a + self.b/2
	-- b sin (c(x-d)) = self.a + self.b/2 - self.a
	--b sin (c(x-d)) = self.b/2
	-- sin(c(x-d)) = (0.5 * self.b)/self.b
	-- sin(c(x-d)) = 1/2
	-- c(x-d) = sin^-1(1/2) = 1/6 pi
	-- cx - dc = 1/6 pi + k * 2pi V cx - dc = pi - 1/6 pi + k * 2pi
	-- cx - dc = 1/6 pi + k * 2pi V cx - dc = - 5/6 pi + k * 2pi
	-- cx = 1/6 pi - dc + k * 2pi V cx = - 5/6 pi - dc + k * 2pi
	-- x = (1/6 pi - dc + k * 2pi)/c V x = (-5/6 pi - dc + k * 2pi) / c
	local SolveFunction1 = function(k) -- delta is 2pi / c
		return (1/6 * math.pi - self.d * self.c + k * 2 * math.pi) / self.c 
	end
	local SolveFunction2 = function(k)
		return (-5/6 * math.pi - self.d * self.c + k * 2 * math.pi) / self.c
	end
	local funcdelta = (math.pi * 2) / self.c
	local Possible1, Possible2 = SolveFunction1(0), SolveFunction2(0)
	local MOD = Last % funcdelta -- Last moved to the last periodic point. In other words middle point.
	return (Last - MOD) + funcdelta/2
end

function Sine:GetPrimitive() -- Returns the area function of the sine. AKA primitive
	if not self.Primitive then
		self.Primitive = function(x)
			return -(self.b/self.c) * math.cos(self.c * x - self.d * self.c)
		end
	end
	return self.Primitive
end

function Sine:GetDerivative()	
	if not self.Derivative then 
		self.Derivative = (function(x) 
		return (self.b*self.c) * math.cos(self.c * (x-self.d))
		end)
	end	
	return self.Derivative
end

function Sine:GetDirection(x) 
	local x = x or self.LastCall or 0
	local Derivative = self:GetDerivative()
	return Derivative(x) < 0 and "decreasing" or Derivative(x) > 0 and "increasing" or "flat"
end

function Sine:GetReverseDirectionX()
	if self(self.LastCall) == self.a + self.b/2 or  self(self.LastCall)== self.a - self.b/2 then 
		return self.LastCall
	end
	local last = self.LastCall or 0
	local e = self(self.LastCall or 0)
	local a,b,c,d = self.a, self.b,self.c, self.d
	local SolutionFunction = function(k)
		return (math.asin((e-a)/b) + k * 2 * math.pi)/c + d
	end
	local SolutionFunction1 = function(k)
		return (math.pi - math.asin((e-a)/b) + k * 2 * math.pi)/c + d
	end
	local try1, try2, try3, try4 = SolutionFunction(0), SolutionFunction1(0), SolutionFunction(1), SolutionFunction(1)
	local offset = math.abs(try1 - try2)
	local offset1 = math.abs(try2-try3)
	local offset2 = math.abs(try3-try4)
	local pos = {}
	
	local max = math.max(offset, offset1, offset2)
	local min = math.min(offset, offset1, offset2)

	local IsUp = self(last) > self.a
	local Direction = self:GetDirection(last)	
	
	local offset = (IsUp and Direction == "increasing" and max) or (IsUp and Direction == "decreasing" and min) or (Direction == "increasing" and min) or max
	
	return (self.LastCall or 0) - offset	
end

math.Sine = Sine
