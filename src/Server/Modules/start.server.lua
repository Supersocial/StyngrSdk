local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = script.Parent

require(ReplicatedStorage.Styngr.Bootstrapper)(Modules)

local StyngrService = require(Modules.StyngrService)

StyngrService.SetConfiguration({
	apiKey = "STYNAPP-kSzCNaZFzonvAs3rALos4Dzw2TxV0K",
	appId = "591711ce-0869-469f-9646-35bff6af8cdc",
})

do
	local _, result = StyngrService:GetPlaylists(3):await()

	print(result)
end
