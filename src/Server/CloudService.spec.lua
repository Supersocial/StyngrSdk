return function()
	local CloudService = require(script.Parent.CloudService)

	local cloudService = CloudService.new(
		"STYNAPP-kSzCNaZFzonvAs3rALos4Dzw2TxV0K",
		"591711ce-0869-469f-9646-35bff6af8cdc",
		"https://tst.api.styngr.com/api/sdk/"
	)

	describe("token creation request", function()
		it("should return a new token for user 1", function()
			local worked, token = cloudService:CreateSDKToken(1):await()

			expect(worked).to.equal(true)
			expect(token).to.be.a("table")
			expect(token.token).to.be.a("string")
		end)
	end)

	describe("getting a token and requesting playlist endpoint", function()
		it("should get or create a token for user 2", function()
			local worked, response = cloudService:GetToken(2):await()

			expect(worked).to.equal(true)
			expect(response).to.be.a("string")
		end)

		it("should get token, and return playlist data", function()
			local getTokenWorked, getTokenResponse = cloudService:GetToken(2):await()

			expect(getTokenWorked).to.equal(true)
			expect(getTokenResponse).to.be.a("string")

			local callWorked, callResponse = cloudService:Call(getTokenResponse, "integration/playlists", "GET"):await()

			print(callResponse)

			expect(callWorked).to.equal(true)
		end)
	end)
end
