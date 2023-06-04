local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local Footer = require(script.Parent.Footer)
local Header = require(script.Parent.Header)

local function Player()
	return New("Frame")({
		Name = "Player",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			Header(),
			Footer(),
		},
	})
end

return Player
