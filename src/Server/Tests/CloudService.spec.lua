local ServerScriptService = game:GetService("ServerScriptService")
return function()
	local CloudService = require(ServerScriptService.Styngr.Modules.CloudService)
	local Config = require(ServerScriptService.Styngr.Tests.Config)

	local cloudService = CloudService.new(Config.Credentials)

	describe("token creation request", function()
		it("should return a new token for user 1", function()
			local worked, token = cloudService:_createToken(1):await()

			expect(worked).to.equal(true)
			expect(token).to.be.a("string")
		end)
	end)

	describe("getting a token and requesting playlist endpoint and then remove the token from cache", function()
		it("should fail cause no token is present for user 2", function()
			local worked = cloudService:_readToken(2):await()
			expect(worked).to.equal(false)
		end)

		it("should create and read token for user 2", function()
			local createTokenWorked, createTokenResult = cloudService:_createToken(2):await()

			expect(createTokenWorked).to.equal(true)
			expect(createTokenResult).to.be.a("string")

			local getTokenWorked, getTokenResult = cloudService:_readToken(2):await()

			expect(getTokenWorked).to.equal(true)
			expect(getTokenResult).to.be.a("string")
		end)

		it("should read token, and return playlist data", function()
			local getTokenWorked, getTokenResponse = cloudService:_readToken(2):await()

			expect(getTokenWorked).to.equal(true)
			expect(getTokenResponse).to.be.a("string")

			local callWorked = cloudService:Call(getTokenResponse, "integration/playlists", "GET"):await()

			expect(callWorked).to.equal(true)
		end)

		it("should remove token from cache", function()
			cloudService:_deleteToken(2)

			local getTokenWorked = cloudService:_readToken(2):await()

			expect(getTokenWorked).to.equal(false)
		end)
	end)
end
