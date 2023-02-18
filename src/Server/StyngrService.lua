local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)

--[[
    StyngrService
    Layer that lives on top of the CloudService module and exposes underlying methods in a more human readable format!
]]
local StyngrService = {}

StyngrService.__index = StyngrService

-- TODO: Include data service here... If we want to handle state!
function StyngrService.new(cloudService)
	assert(cloudService, "Please pass in a CloudService!")

	local self = {
		_cloudService = cloudService,
	}

	setmetatable(self, StyngrService)

	return self
end

function StyngrService:GetPlaylists(userId: number)
	assert(self._cloudService, "No cloudService present...") -- TODO: This might be redundant, doesn't hurt to check though!

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
	assert(self._cloudService, "No cloudService present...")

	--[[
		TODO: Determine logical flow here, along with how we want to handle state.
		-> some of the current endpoints indicate that the backend is tracking some leevel of state,
		-> wondering if we want to offload state entirely to them or if we should handle state on our end as well,
		-> the latter option seems higher complexity and could cause edge cases where state on our end doesn't align with the backend,
	]]
end

return StyngrService
