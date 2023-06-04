local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Computed = Fusion.Computed

local ProgressState = require(StarterPlayer.StarterPlayerScripts.Styngr.ProgressState)

local Line = {}

function Line:Render()
	self.line = New("Frame")({
		Name = "Line",
		BackgroundColor3 = Color3.fromRGB(122, 247, 255),
		Size = Computed(function()
			return UDim2.fromScale(ProgressState:get(), 1)
		end),
		Position = UDim2.fromScale(0, 0),
	})

	return self.line
end

return Line
