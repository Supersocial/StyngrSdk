--[=[
	@class StyngrService

	Core service for all server side SDK methods
]=]
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local CloudService = require(ServerScriptService.Styngr.Modules.CloudService)
local Types = require(ServerScriptService.Styngr.Types)
local ISODurations = require(ReplicatedStorage.Styngr.Utils.ISODurations)

local Products = {
	[1549281432] = "SUBSCRIPTION_RADIO_BUNDLE_LARGE",
	[1549281380] = "SUBSCRIPTION_RADIO_BUNDLE_MEDIUM",
	[1549281250] = "SUBSCRIPTION_RADIO_BUNDLE_SMALL",
}

local StyngrService = {}

function StyngrService.BuildClientFriendlyTrack(userId, track)
	print("track", track)
	assert(
		track
			and typeof(track["customMetadata"]) == "table"
			and typeof(track["title"]) == "string"
			and typeof(track["artistNames"]) == "table"
			and typeof(track["isLiked"]) == "boolean",
		"Please ensure the passed in track is valid and contains all necessary values."
	)

	local customMetadata = track.customMetadata

	assert(
		typeof(customMetadata["key"]) == "string" and typeof(customMetadata["id"]) == "string",
		"Track's custom metadata does not contain necessary information."
	)

	print("customMetadata", customMetadata)
	print("userId", userId)

	local encryptionKey = game:GetService("NetworkServer"):EncryptStringForPlayerId(customMetadata.key, userId)

	return {
		title = track.title,
		artistNames = track.artistNames,
		isLiked = track.isLiked,
		assetId = customMetadata.id,
		encryptionKey = encryptionKey,
	}
end

function StyngrService:_getPlayersPlaylists(userId: number)
	return self._playlists[userId]
end

function StyngrService:_setPlayersPlaylists(userId: number, playlists)
	self._playlists[userId] = playlists
end

function StyngrService:_getSession(userId: number)
	return self._sessions[userId]
end

function StyngrService:_setSession(userId: number, session)
	self._sessions[userId] = session
end

function StyngrService:_startTrack(userId: number)
	assert(not self._tracking[userId], "Already tracking for this user!")

	self._tracking[userId] = {
		started = os.time(),
		totalPaused = 0,
	}
end

function StyngrService:_endTrack(userId: number)
	local statistics = self._tracking[userId]

	assert(statistics, "No active tracking for the specified user could be found!")

	self._tracking[userId] = nil

	local endTime = statistics.ended or os.time()

	local duration = endTime - statistics.started

	duration -= statistics.totalPaused

	return {
		started = statistics.started,
		ended = endTime,
		duration = duration,
	}
end

function StyngrService:_clientTrackEvent(userId: number, event)
	print(userId, event, os.time())
	assert(event and (event == "PLAYED" or event == "ENDED" or event == "RESUMED" or event == "PAUSED"))

	local statistics = self._tracking[userId]

	assert(statistics)

	if event == "PLAYED" then
		assert(not statistics.ended)

		statistics.started = os.time()
	elseif event == "ENDED" then
		assert(statistics.started)

		local ended = os.time()

		assert(statistics.started <= ended)

		statistics.ended = ended
	elseif event == "RESUMED" then
		local paused = os.time() - statistics.paused

		assert(paused >= 0)

		statistics.paused = nil
		statistics.totalPaused += paused
	elseif event == "PAUSED" then
		assert(not statistics.paused)

		statistics.paused = os.time()
	end

	self._tracking[userId] = statistics
end

function StyngrService:_getPlaylistsRaw(player: Player)
	return self._cloudService
		:GetToken(player)
		:andThen(function(token)
			return self._cloudService:Call(token, "/v2/sdk/integration/playlists", "GET")
		end)
		:andThen(function(result)
			return Promise.new(function(resolve, reject)
				local body = HttpService:JSONDecode(result.Body)

				if body["playlists"] then
					resolve(body)
				else
					reject()
				end
			end)
		end)
end

--[=[
	For setting up the SDK with your API credentials

	@param inputConfiguration { apiKey: string, appId: string, apiServer: string? } -- Contains your API credentials
]=]
function StyngrService:SetConfiguration(inputConfiguration: Types.StyngrServiceConfiguration)
	assert(
		inputConfiguration
			and inputConfiguration.apiKey
			and typeof(inputConfiguration.apiKey) == "string"
			and inputConfiguration.appId
			and typeof(inputConfiguration.appId) == "string",
		"Please specify a configuration and ensure all values are correct!"
	)

	if inputConfiguration.apiServer then
		assert(
			typeof(inputConfiguration.apiServer) == "string",
			"Please specify a configuration and ensure all values are correct!"
		)
	else
		inputConfiguration.apiServer = "https://stg.api.styngr.com/api"
	end

	if self._connections then
		for _, connection in self._connections do
			connection:Disconnect()
		end
	end

	self._cloudService = CloudService.new(inputConfiguration)
	self._configuration = inputConfiguration
	self._sessions = {}
	self._tracking = {}
	self._connections = {}
	self._playlists = {}

	local SongEventsConnection = ReplicatedStorage.Styngr.SongEvents.OnServerEvent:Connect(
		function(player: Player, event)
			self:_clientTrackEvent(player.UserId, event)
		end
	)

	table.insert(self._connections, SongEventsConnection)

	ReplicatedStorage.Styngr.GetPlaylists.OnServerInvoke = function(player)
		local ok, result = self:GetPlaylists(player):await()

		assert(ok, "Failed to get playlists!")

		return result
	end

	ReplicatedStorage.Styngr.StartPlaylistSession.OnServerInvoke = function(player, playlistId)
		assert(typeof(playlistId) == "string")

		local ok, session = self:StartPlaylistSession(player, playlistId):await()

		print(session)

		assert(ok, "Failed to start playlist session!")

		return StyngrService.BuildClientFriendlyTrack(player.UserId, session.track)
	end

	ReplicatedStorage.Styngr.RequestNextTrack.OnServerInvoke = function(player)
		local ok, session = self:RequestNextTrack(player):await()

		assert(ok and session, "Failed to request next track!")

		return StyngrService.BuildClientFriendlyTrack(player.UserId, session.track)
	end

	ReplicatedStorage.Styngr.SkipTrack.OnServerInvoke = function(player)
		local ok, session = self:SkipTrack(player):await()

		assert(ok and session, "Failed to request next track!")

		return StyngrService.BuildClientFriendlyTrack(player.UserId, session.track)
	end

	ReplicatedStorage.Styngr.GetNumberOfStreamsAvailable.OnServerInvoke = function(player)
		local ok, session = self:GetNumberOfStreamsAvailable(player):await()

		assert(ok, "Failed to request number of streams!")

		return session
	end

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		-- Find the player who made the purchase in the server
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			-- The player probably left the game
			-- If they come back, the callback will be called again
			return nil
		end

		local bundleToPurchase = Products[receiptInfo.ProductId]

		if not bundleToPurchase then
			return nil
		end

		return self:CreateAndConfirmTransaction(player, bundleToPurchase):andThen(function()
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end, function(error)
			warn(error)

			return nil
		end)
	end
end

--[=[
	Gets all accessible playlists for the specified userId
	@param userId number -- The player you're requesting on behalf of
	@return Promise<{{ description: string?, duration: number, id: string, title: string?, trackCount: number }}>
]=]
function StyngrService:GetPlaylists(player: Player)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	return self:_getPlaylistsRaw(player):andThen(function(body)
		return Promise.new(function(resolve)
			local playlistsById = {}

			for _, playlist in body["playlists"] do
				playlistsById[playlist.id] = playlist
			end

			self:_setPlayersPlaylists(player.UserId, playlistsById)

			resolve(body["playlists"])
		end)
	end)
end

function StyngrService:StartPlaylistSession(player: Player, playlistId: string)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	local existingSession = self:_getSession(player.UserId)

	if existingSession and existingSession.playlistId == playlistId then
		-- TODO: This is potentially bad, let's think through resuming AND switching between playlists (maybe we need some state to determine if a playlist is currently playing?)
		return Promise.new(function(_, reject)
			reject("An existing session for this playlist is already in action!")
		end)
	end

	return self._cloudService
		:GetToken(player)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"/v2/sdk/integration/playlists/" .. playlistId .. "/start?trackFormat=AAC&createAssetUrl=false",
				"POST"
			)
		end)
		:andThen(function(result)
			return Promise.new(function(resolve)
				local session = HttpService:JSONDecode(result.Body)

				session.playlistId = playlistId
				session.tracksPlayed = 1

				self:_startTrack(player.UserId)
				self:_setSession(player.UserId, session)

				resolve(session)
			end)
		end)
end

function StyngrService:RequestNextTrack(player: Player)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	local session = self:_getSession(player.UserId)

	assert(session, "No session found for user " .. player.UserId .. "!")

	local playlist = self:_getPlayersPlaylists(player.UserId)[session.playlistId]

	assert(playlist, "This playlist does not exist for the user!")

	local statistics = self:_endTrack(player.UserId)
	local duration = ISODurations.TranslateSecondsToDuration(statistics.duration)

	if session.tracksPlayed >= playlist.trackCount then
		self:_setSession(player.UserId, nil)

		-- TODO: Report statistics!

		return Promise.new(function(resolve)
			resolve(nil)
		end)
	end

	return self._cloudService
		:GetToken(player)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"/v2/sdk/integration/playlists/" .. session.playlistId .. "/next?createAssetUrl=false",
				"POST",
				{
					sessionId = session.sessionId,
					format = "AAC",
					statistics = {
						{
							trackId = session.track.trackId,
							start = DateTime.fromUnixTimestamp(statistics.started):ToIsoDate(),
							duration = duration,
							autoplay = true,
							isMuted = false,
							clientTimestampOffset = "",
						},
					},
				}
			)
		end)
		:andThen(function(result)
			return Promise.new(function(resolve)
				local track = HttpService:JSONDecode(result.Body)

				session.track = track
				session.tracksPlayed += 1

				self:_startTrack(player.UserId)
				self:_setSession(player.UserId, session)

				resolve(session)
			end)
		end)
		:catch(function()
			print("hello")
		end)
end

function StyngrService:SkipTrack(player: Player)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	local session = self:_getSession(player.UserId)

	assert(session, "No session found for user " .. player.UserId .. "!")

	local playlist = self:_getPlayersPlaylists(player.UserId)[session.playlistId]

	assert(playlist, "This playlist does not exist for the user!")

	local statistics = self:_endTrack(player.UserId)
	local duration = ISODurations.TranslateSecondsToDuration(statistics.duration)

	if session.tracksPlayed >= playlist.trackCount then
		self:_setSession(player.UserId, nil)

		-- TODO: Report statistics!

		return Promise.new(function(resolve)
			resolve(nil)
		end)
	end

	return self._cloudService
		:GetToken(player)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"/v2/sdk/integration/playlists/" .. session.playlistId .. "/skip?createAssetUrl=false",
				"POST",
				{
					sessionId = session.sessionId,
					format = "AAC",
					statistics = {
						{
							trackId = session.track.trackId,
							start = DateTime.fromUnixTimestamp(statistics.started):ToIsoDate(),
							duration = duration,
							autoplay = true,
							isMuted = false,
							clientTimestampOffset = "",
						},
					},
				}
			)
		end)
		:andThen(function(result)
			return Promise.new(function(resolve)
				local track = HttpService:JSONDecode(result.Body)

				session.track = track
				session.tracksPlayed += 1

				self:_startTrack(player.UserId)
				self:_setSession(player.UserId, session)

				resolve(session)
			end)
		end)
end

function StyngrService:GetNumberOfStreamsAvailable(player: Player)
	return self:_getPlaylistsRaw(player):andThen(function(body)
		return Promise.new(function(resolve)
			if body["remainingNumberOfStreams"] then
				resolve(body["remainingNumberOfStreams"])
			else
				resolve(0)
			end
		end)
	end)
end

function StyngrService:GetAvailableRadioBundles(player: Player)
	return self._cloudService
		:GetToken(player)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"/v1/sdk/radio/" .. self._configuration.appId .. "/bundle/available",
				"GET"
			)
		end)
		:andThen(function(result)
			return Promise.new(function(resolve, reject)
				local parsedBody = HttpService:JSONDecode(result.Body)

				if parsedBody["availableRadioBundles"] then
					resolve(parsedBody["availableRadioBundles"])
					return
				end

				reject("Invalid response, no availableRadioBundles present in response.")
			end)
		end)
end

function StyngrService:_createTransaction(token: string, bundleToPurchase: string)
	return self._cloudService
		:Call(token, "/v1/sdk/radio/" .. self._cloudService._configuration.appId .. "/bundle/purchase", "POST", {
			["bundleToPurchase"] = bundleToPurchase,
		})
		:andThen(function(rawPurchaseResponse)
			return Promise.new(function(resolve, reject)
				local purchaseBody = HttpService:JSONDecode(rawPurchaseResponse.Body)

				if purchaseBody["transactionId"] then
					resolve(purchaseBody["transactionId"])
				else
					reject("No transactionId present on purchase body response")
				end
			end)
		end)
end

function StyngrService:_confirmTransaction(player: Player, transactionId: string)
	return Promise.new(function(resolve)
		resolve(LocalizationService:GetCountryRegionForPlayerAsync(player))
	end):andThen(function(countryRegion)
		return self._cloudService:CallAsApi("/v1/sdk/payments/confirm", "POST", {
			trxId = transactionId,
			appId = self._cloudService._configuration.appId,
			billingType = "BUNDLE",
			payType = "NP",
			subscriptionId = "",
			userIp = "",
			billingCountry = countryRegion,
		})
	end)
end

function StyngrService:CreateAndConfirmTransaction(player: Player, bundleToPurchase: string)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	return self._cloudService:GetToken(player):andThen(function(token)
		return self:_createTransaction(token, bundleToPurchase):andThen(function(transactionId)
			return self:_confirmTransaction(player, transactionId)
		end)
	end)
end

return StyngrService
