local StyngrService = require(script.Parent.StyngrService)

StyngrService.SetConfiguration({
	apiKey = "STYNAPP-kSzCNaZFzonvAs3rALos4Dzw2TxV0K",
	appId = "591711ce-0869-469f-9646-35bff6af8cdc",
})

do
	local _, result = StyngrService:GetPlaylists(3):await()

	print(result)
end
