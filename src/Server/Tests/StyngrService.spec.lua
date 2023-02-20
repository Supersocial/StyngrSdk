local ServerScriptService = game:GetService("ServerScriptService")
return function()
	local StyngrService = require(ServerScriptService.Styngr.Modules.StyngrService)

	StyngrService:Init()

	StyngrService:Start()

	StyngrService.SetConfiguration({
		apiKey = "STYNAPP-kSzCNaZFzonvAs3rALos4Dzw2TxV0K",
		appId = "591711ce-0869-469f-9646-35bff6af8cdc",
		apiServer = "https://tst.api.styngr.com/api/sdk/",
	})

	describe("requests", function()
		it("gets playlists", function()
			local getPlaylistsWorked, getPlaylistsResult = StyngrService:GetPlaylists(1):await()

			expect(getPlaylistsWorked).to.equal(true)

			expect(getPlaylistsResult).to.be.a("table")
		end)
	end)
end
