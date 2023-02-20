local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local CloudService = require(script.Parent.CloudService)

--[[
    StyngrService
    Layer that lives on top of the CloudService module and exposes underlying methods in a more human readable format!
]]
local StyngrService = {}

local cloudService

type StyngrServiceConfiguration = {
	apiKey: string,
	appId: string,
	apiServer: string?,
}

function StyngrService.SetConfiguration(inputConfiguration: StyngrServiceConfiguration)
	inputConfiguration.apiServer = if inputConfiguration.apiServer
		then inputConfiguration.apiServer
		else "https://tst.api.styngr.com/api/sdk/"

	cloudService = CloudService.new(inputConfiguration)

	Players.PlayerRemoving:Connect(function(player)
		cloudService:DeleteToken(player.UserId)
	end)
end

function StyngrService:GetPlaylists(userId: number)
	assert(
		cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	return cloudService
		:GetToken(userId)
		:andThen(function(token)
			return cloudService:Call(token, "integration/playlists", "GET")
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
		cloudService,
		"Please initialize StyngrService using StyngrService.SetConfiguration() before calling this method!"
	)

	--[[
		TODO: Determine logical flow here, along with how we want to handle state.
		-> some of the current endpoints indicate that the backend is tracking some leevel of state,
		-> wondering if we want to offload state entirely to them or if we should handle state on our end as well,
		-> the latter option seems higher complexity and could cause edge cases where state on our end doesn't align with the backend,
	]]
end

return StyngrService
