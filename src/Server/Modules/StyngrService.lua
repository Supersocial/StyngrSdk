--[=[
	@class StyngrService

	Core service for all server side SDK methods
]=]
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local CloudService = require(ServerScriptService.Styngr.Modules.CloudService)
local Types = require(ServerScriptService.Styngr.Types)
local ISODurations = require(ReplicatedStorage.Styngr.Utils.ISODurations)

local StyngrService = {}

function StyngrService.BuildClientFriendlyTrack(userId, track, robloxTrack)
	local encryptionKey = game:GetService("NetworkServer"):EncryptStringForPlayerId(robloxTrack.key, userId)

	return {
		title = track.title,
		artistNames = track.artistNames,
		isLiked = track.isLiked,
		assetId = robloxTrack.id,
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
		inputConfiguration.apiServer = "https://stg.api.styngr.com/api/v1/sdk/"
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
		local ok, result = self:GetPlaylists(player.UserId):await()

		assert(ok, "Failed to get playlists!")

		return result
	end

	ReplicatedStorage.Styngr.StartPlaylistSession.OnServerInvoke = function(player, playlistId)
		assert(typeof(playlistId) == "string")

		local ok, session = self:StartPlaylistSession(player.UserId, playlistId):await()

		assert(ok, "Failed to start playlist session!")

		local track = session.track
		local robloxTrack = self:TEMPGetRobloxTrack(track.audioAssetId)

		return StyngrService.BuildClientFriendlyTrack(player.UserId, track, robloxTrack)
	end

	ReplicatedStorage.Styngr.RequestNextTrack.OnServerInvoke = function(player)
		local ok, session = self:RequestNextTrack(player.UserId):await()

		print(session)

		assert(ok and session, "Failed to request next track!")

		local track = session.track
		local robloxTrack = self:TEMPGetRobloxTrack(track.audioAssetId)

		return StyngrService.BuildClientFriendlyTrack(player.UserId, track, robloxTrack)
	end

	ReplicatedStorage.Styngr.SkipTrack.OnServerInvoke = function(player)
		local ok, session = self:SkipTrack(player.UserId):await()

		print(session)

		assert(ok and session, "Failed to request next track!")

		local track = session.track
		local robloxTrack = self:TEMPGetRobloxTrack(track.audioAssetId)

		return StyngrService.BuildClientFriendlyTrack(player.UserId, track, robloxTrack)
	end
end

--[=[
	Gets all accessible playlists for the specified userId
	@param userId number -- The player you're requesting on behalf of
	@return Promise<{{ description: string?, duration: number, id: string, title: string?, trackCount: number }}>
]=]
function StyngrService:GetPlaylists(userId: number)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	return self._cloudService
		:GetToken(userId)
		:andThen(function(token)
			return self._cloudService:Call(token, "integration/playlists", "GET")
		end)
		:andThen(function(result)
			return Promise.new(function(resolve, reject)
				local body = HttpService:JSONDecode(result.Body)

				if body["playlists"] then
					local playlistsById = {}

					for _, playlist in body["playlists"] do
						playlistsById[playlist.id] = playlist
					end

					self:_setPlayersPlaylists(userId, playlistsById)

					resolve(body["playlists"])
				else
					reject()
				end
			end)
		end)
end

function StyngrService:StartPlaylistSession(userId: number, playlistId: string)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	local existingSession = self:_getSession(userId)

	if existingSession and existingSession.playlistId == playlistId then
		-- TODO: This is potentially bad, let's think through resuming AND switching between playlists (maybe we need some state to determine if a playlist is currently playing?)
		return Promise.new(function(_, reject)
			reject("An existing session for this playlist is already in action!")
		end)
	end

	return self._cloudService
		:GetToken(userId)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"integration/playlists/" .. playlistId .. "/start?trackFormat=AAC&createAssetUrl=false",
				"POST"
			)
		end)
		:andThen(function(result)
			return Promise.new(function(resolve)
				local session = HttpService:JSONDecode(result.Body)

				session.playlistId = playlistId
				session.tracksPlayed = 1

				self:_startTrack(userId)
				self:_setSession(userId, session)

				resolve(session)
			end)
		end)
end

--[[
	TEMPORARY METHOD WHILE API PARTNER IS WORKING ON THEIR SOLUTION
]]
function StyngrService:TEMPGetRobloxTrack(mediaNetId: number)
	local mediaNetIdsToRoblox = {
		[774981] = {
			id = "rbxassetid://11090605228",
			key = "3471684a805fe3a498153616285cb5f1c368d039a89b8be2395b2366083b8d79",
		},
		[598680043] = {
			id = "rbxassetid://11090606768",
			key = "ccc97c202ebd435557b1594e98e5fc37b6ba7c7ed8dca31ef30c33800e3cde57",
		},
		[550236843] = {
			id = "rbxassetid://11090610497",
			key = "c617300ebd19018b311901e06934757c37ef6f2df35b1eba79d85564ccb33090",
		},
		[93210735] = {
			id = "rbxassetid://11090608083",
			key = "c9fb002e055d78bae8db171d1b685c78319f75692810e968ad8cacada8ffbd2a",
		},
		[778843] = {
			id = "rbxassetid://11090609300",
			key = "6d582087e7cff668be72919c12f846d716c353f474a04d01d62de612a23759a5",
		},
	}

	local robloxTrack = mediaNetIdsToRoblox[mediaNetId]

	assert(robloxTrack, "Failed to map external track with internal table")

	return robloxTrack
end

function StyngrService:RequestNextTrack(userId: number)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	local session = self:_getSession(userId)

	assert(session, "No session found for user " .. userId .. "!")

	local playlist = self:_getPlayersPlaylists(userId)[session.playlistId]

	assert(playlist, "This playlist does not exist for the user!")

	local statistics = self:_endTrack(userId)
	local duration = ISODurations.TranslateSecondsToDuration(statistics.duration)

	if session.tracksPlayed >= playlist.trackCount then
		self:_setSession(userId, nil)

		-- TODO: Report statistics!

		return Promise.new(function(resolve)
			resolve(nil)
		end)
	end

	return self._cloudService
		:GetToken(userId)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"integration/playlists/" .. session.playlistId .. "/next?createAssetUrl=false",
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

				self:_startTrack(userId)
				self:_setSession(userId, session)

				resolve(session)
			end)
		end)
		:catch(function()
			print("hello")
		end)
end

function StyngrService:SkipTrack(userId: number)
	assert(
		self._cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	local session = self:_getSession(userId)

	assert(session, "No session found for user " .. userId .. "!")

	local playlist = self:_getPlayersPlaylists(userId)[session.playlistId]

	assert(playlist, "This playlist does not exist for the user!")

	local statistics = self:_endTrack(userId)
	local duration = ISODurations.TranslateSecondsToDuration(statistics.duration)

	if session.tracksPlayed >= playlist.trackCount then
		self:_setSession(userId, nil)

		-- TODO: Report statistics!

		return Promise.new(function(resolve)
			resolve(nil)
		end)
	end

	return self._cloudService
		:GetToken(userId)
		:andThen(function(token)
			return self._cloudService:Call(
				token,
				"integration/playlists/" .. session.playlistId .. "/skip?createAssetUrl=false",
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

				self:_startTrack(userId)
				self:_setSession(userId, session)

				resolve(session)
			end)
		end)
end

return StyngrService
