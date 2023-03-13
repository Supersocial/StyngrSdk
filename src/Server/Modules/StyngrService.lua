--[=[
	@class StyngrService

	Core service for all server side SDK methods
]=]
local ContentProvider = game:GetService("ContentProvider")

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local CloudService = require(ServerScriptService.Styngr.Modules.CloudService)
local Types = require(ServerScriptService.Styngr.Types)

local StyngrService = {}

function StyngrService:_getSession(userId: number)
	return self._sessions[userId]
end

function StyngrService:_setSession(userId: number, session)
	self._sessions[userId] = session
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

	self._cloudService = CloudService.new(inputConfiguration)
	self._configuration = inputConfiguration
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
		return existingSession
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
							start = DateTime.now():ToIsoDate(),
							duration = "PT3M",
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

				resolve(session)
			end)
		end)
end

local function buildClientFriendlyTrack(userId, track, robloxTrack)
	local encryptionKey = game:GetService("NetworkServer"):EncryptStringForPlayerId(robloxTrack.key, userId)

	return {
		title = track.title,
		artistNames = track.artistNames,
		isLiked = track.isLiked,
		assetId = robloxTrack.id,
		encryptionKey = encryptionKey,
	}
end

--[[
	Initialization method
]]
function StyngrService:Init()
	self._cloudService = {}
	self._configuration = {}
	self._sessions = {}

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

		return buildClientFriendlyTrack(player.UserId, track, robloxTrack)
	end

	ReplicatedStorage.Styngr.RequestNextTrack.OnServerInvoke = function(player)
		local ok, session = self:RequestNextTrack(player.UserId):await()

		assert(ok, "Failed to request next track!")

		local track = session.track
		local robloxTrack = self:TEMPGetRobloxTrack(track.audioAssetId)

		return buildClientFriendlyTrack(player.UserId, track, robloxTrack)
	end
end

--[[
	Start method
]]
function StyngrService:Start() end

return StyngrService
