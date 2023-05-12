require(script.Parent.StyngrClient)

--[[ Example with custom button

local Players = game:GetService("Players")
local StyngrClient = require(script.Parent.StyngrClient)

StyngrClient:SetVisible(false)

local StyngrCustom = Players.LocalPlayer.PlayerGui:WaitForChild("StyngrCustom")
local CustomButton = StyngrCustom.CustomButton :: TextButton

CustomButton.Activated:Connect(function()
	StyngrClient:Toggle()
end) ]]
