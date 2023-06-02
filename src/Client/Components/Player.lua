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

		-- AnchorPoint = Vector2.new(0.5, 0.5),
		-- BackgroundColor3 = Color3.fromRGB(34, 34, 34),
		-- BackgroundTransparency = 0,
		-- Position = UDim2.fromScale(0.5, 0.5),
		-- Size = UDim2.fromScale(0.313, 0.186),

		[Children] = {
			Header(),
			Footer(),
		},
	})
end

return Player
