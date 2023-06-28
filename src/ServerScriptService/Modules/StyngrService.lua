--[=[
	@class StyngrService

	Core service for all server side SDK methods
]=]
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local CloudService = require(ServerScriptService.Styngr.Modules.CloudService)
local Types = require(ServerScriptService.Styngr.Types)
local ISODurations = require(ReplicatedStorage.Styngr.Utils.ISODurations)

local StyngrService = {}

function StyngrService.BuildClientFriendlyTrack(userId, track)
	assert(
		track
			and typeof(track["customMetadata"]) == "table"
			and typeof(track["title"]) == "string"
			and typeof(track["artistNames"]) == "table"
			and typeof(track["isLiked"]) == "boolean"
			and typeof(track["playlistId"] == "string"),
		"Please ensure the passed in track is valid and contains all necessary values."
	)

	local customMetadata = track.customMetadata

	assert(
		typeof(customMetadata["key"]) == "string" and typeof(customMetadata["id"]) == "string",
		"Track's custom metadata does not contain necessary information."
	)

	local encryptionKey = game:GetService("NetworkServer"):EncryptStringForPlayerId(customMetadata.key, userId)

	return {
		title = track.title,
		artistNames = track.artistNames,
		isLiked = track.isLiked,
		assetId = customMetadata.id,
		encryptionKey = encryptionKey,
		playlistId = track.playlistId,
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
	self._boomboxModels = {}

	local SongEventsConnection = ReplicatedStorage.Styngr.SongEvents.OnServerEvent:Connect(
		function(player: Player, event)
			self:_clientTrackEvent(player.UserId, event)

			-- Get or create boombox model
			local boomboxModel = self._boomboxModels[player] or self:_makeBoomboxModel()
			self._boomboxModels[player] = boomboxModel

			local character = player.Character
			
			if (event == "PLAYED" or event == "RESUMED") then
				local gripAttachment = character:FindFirstChild("RightGripAttachment", true)
				boomboxModel.CFrame = gripAttachment.WorldCFrame
				boomboxModel.BallSocketConstraint.Attachment1 = gripAttachment
				boomboxModel.Parent = character
			else
				boomboxModel.Parent = nil
			end
		end
	)

	table.insert(self._connections, SongEventsConnection)

	ReplicatedStorage.Styngr.GetPlaylists.OnServerInvoke = function(player)
		local ok, result = self:GetPlaylists(player):await()

		if not ok or not result then
			return nil
		end

		return result
	end

	ReplicatedStorage.Styngr.StartPlaylistSession.OnServerInvoke = function(player, playlistId)
		assert(typeof(playlistId) == "string")

		local ok, session = self:StartPlaylistSession(player, playlistId):await()

		if not ok or not session then
			return nil
		end

		session.track.playlistId = playlistId

		return StyngrService.BuildClientFriendlyTrack(player.UserId, session.track)
	end

	ReplicatedStorage.Styngr.RequestNextTrack.OnServerInvoke = function(player)
		local ok, session = self:RequestNextTrack(player):await()

		if not ok or not session then
			return nil
		end

		return StyngrService.BuildClientFriendlyTrack(player.UserId, session.track)
	end

	ReplicatedStorage.Styngr.SkipTrack.OnServerInvoke = function(player)
		local ok, session = self:SkipTrack(player):await()

		if not ok or not session then
			return nil
		end

		return StyngrService.BuildClientFriendlyTrack(player.UserId, session.track)
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

	local _ = self:CreateAndConfirmTransaction(player, "SUBSCRIPTION_RADIO_BUNDLE_FREE"):await()

	return self:_getPlaylistsRaw(player)
		:andThen(function(body)
			return Promise.new(function(resolve)
				local playlistsById = {}

				for _, playlist in body["playlists"] do
					playlistsById[playlist.id] = playlist
				end

				self:_setPlayersPlaylists(player.UserId, playlistsById)

				resolve(body)
			end)
		end)
		:catch(function(error)
			warn(error)
		end)
end

function StyngrService:StartPlaylistSession(player: Player, playlistId: string)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

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
		:catch(function(error)
			warn(error)
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

				track.playlistId = session.playlistId

				session.track = track
				session.tracksPlayed += 1

				self:_startTrack(player.UserId)
				self:_setSession(player.UserId, session)

				resolve(session)
			end)
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

				track.playlistId = session.playlistId

				session.track = track
				session.tracksPlayed += 1

				self:_startTrack(player.UserId)
				self:_setSession(player.UserId, session)

				resolve(session)
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

--[[
	Creates a boombox model. We do this manually and by hand instead of a 
	RBXM packaged with the SDK because the mesh ID is hot-swappable, and can't
	require a re-build of the RBXM.
]]
function StyngrService:_makeBoomboxModel()
	local boombox = Instance.new("Part")
	boombox.Name = "BoomboxModel"
	boombox.Size = Vector3.new(2.2, 1.2, 0.5)
	boombox.CanCollide = false
	boombox.Massless = true

	local attachment = Instance.new("Attachment")
	attachment.Parent = boombox
	attachment.CFrame = CFrame.new(0, boombox.Size.Y / 2, 0) * CFrame.Angles(0, math.rad(65), 0)
	
	local socket = Instance.new("BallSocketConstraint")
	socket.LimitsEnabled = true
	socket.UpperAngle = 20
	socket.Restitution = 1
	socket.Attachment0 = attachment
	socket.Parent = boombox
	socket.MaxFrictionTorque = 15

	local mesh = Instance.new("SpecialMesh")
	mesh.Parent = boombox
	mesh.MeshId = "rbxassetid://13894568565"
	mesh.TextureId = self._configuration.boombox.textureId
	mesh.Scale = Vector3.new(0.05, 0.05, 0.05)

	return boombox
end

return StyngrService
