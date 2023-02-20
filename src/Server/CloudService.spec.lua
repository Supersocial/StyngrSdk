return function()
	local CloudService = require(script.Parent.CloudService)

	-- TODO: This test can be polluted now,

	local cloudService = CloudService.new({
		apiKey = "STYNAPP-kSzCNaZFzonvAs3rALos4Dzw2TxV0K",
		appId = "591711ce-0869-469f-9646-35bff6af8cdc",
		apiServer = "https://tst.api.styngr.com/api/sdk/",
	})

	describe("token creation request", function()
		it("should return a new token for user 1", function()
			local worked, token = cloudService:CreateToken(1):await()

			expect(worked).to.equal(true)
			expect(token).to.be.a("string")
		end)
	end)

	describe("getting a token and requesting playlist endpoint and then remove the token from cache", function()
		it("should fail cause no token is present for user 2", function()
			local worked = cloudService:ReadToken(2):await()
			expect(worked).to.equal(false)
		end)

		it("should create and get token for user 2", function()
			local createTokenWorked, createTokenResult = cloudService:CreateToken(2):await()

			expect(createTokenWorked).to.equal(true)
			expect(createTokenResult).to.be.a("string")

			local getTokenWorked, getTokenResult = cloudService:ReadToken(2):await()

			expect(getTokenWorked).to.equal(true)
			expect(getTokenResult).to.be.a("string")
		end)

		it("should get token, and return playlist data", function()
			local getTokenWorked, getTokenResponse = cloudService:ReadToken(2):await()

			expect(getTokenWorked).to.equal(true)
			expect(getTokenResponse).to.be.a("string")

			local callWorked = cloudService:Call(getTokenResponse, "integration/playlists", "GET"):await()

			expect(callWorked).to.equal(true)
		end)

		it("should remove token from cache", function()
			cloudService:DeleteToken(2)

			local getTokenWorked = cloudService:ReadToken(2):await()

			expect(getTokenWorked).to.equal(false)
		end)
	end)
end
