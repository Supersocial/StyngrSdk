local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Observer = Fusion.Observer
local Tween = Fusion.Tween
local Value = Fusion.Value

local State = require(ReplicatedStorage.Styngr.State)

local Line = {}

local goal = Value(UDim2.fromScale(0, 1))
local tweenInfo = Value(TweenInfo.new(1))
local lineTween = Tween(goal, tweenInfo)

function Line:Render()
	self.line = New("Frame")({
		Name = "Line",
		BackgroundColor3 = Color3.fromRGB(122, 247, 255),
		Size = lineTween,
		Position = UDim2.fromScale(0, 0),
	})

	return self.line
end

local observer = Observer(State)

observer:onChange(function()
	local nowPlaying = State:get().nowPlaying

	if nowPlaying then
		tweenInfo:set(TweenInfo.new(nowPlaying.timeLength))
		goal:set(UDim2.fromScale(1, 1))
	else
		tweenInfo:set(TweenInfo.new(0))
		goal:set(UDim2.fromScale(0, 1))
	end
end)

observer:update()

return Line
