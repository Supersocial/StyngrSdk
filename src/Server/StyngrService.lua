local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)

--[[
    StyngrService
    Layer that lives on top of the CloudService module and exposes underlying methods in a more human readable format!
]]
local StyngrService = {}

StyngrService.__index = StyngrService

function StyngrService.new(cloudService)
	assert(cloudService, "Please pass in a CloudService!")

	local self = {
		_cloudService = cloudService,
	}

	setmetatable(self, StyngrService)

	return self
end

function StyngrService:GetPlaylists(userId: number)
	assert(self._cloudService, "No cloudService present...")

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

return StyngrService
