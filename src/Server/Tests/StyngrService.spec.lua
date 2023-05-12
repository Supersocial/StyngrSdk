local ServerScriptService = game:GetService("ServerScriptService")
return function()
	local StyngrService = require(ServerScriptService.Styngr.Modules.StyngrService)
	local Config = require(ServerScriptService.Styngr.Tests.Config)

	StyngrService:Init()

	StyngrService:Start()

	StyngrService:SetConfiguration(Config.Credentials)

	describe("requests", function()
		it("gets playlists", function()
			local getPlaylistsWorked, getPlaylistsResult = StyngrService:GetPlaylists(1):await()

			expect(getPlaylistsWorked).to.equal(true)

			expect(getPlaylistsResult).to.be.a("table")
		end)
	end)
end
