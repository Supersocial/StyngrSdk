local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = script.Parent

require(ReplicatedStorage.Styngr.Bootstrapper)(Modules)

local StyngrService = require(Modules.StyngrService)

StyngrService:SetConfiguration({
	apiKey = "STYNAPP-OLcebRdIm4dHWfACSuCPcDb4ENzcFS",
	appId = "892376d0-0d9f-49d4-ad66-44dd2826d68a",
})
