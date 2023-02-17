local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)

--[[
    CloudService
    Serves as a middleware between HTTPService and StyngrService, handles things like token storage, refreshing.
]]
local CloudService = {}

local ENVIRONMENT_VARIABLES = {
    API_KEY = "",
    API_ID = ""
}

local refreshToken

--[[
    Wraps around every call to external API, ensures token is refreshed and handles errors in a graceful-ish matter
]]
function CloudService:Call()
    return Promise.new(function(resolve, reject)

    end)
end

--[[
    Initialization method
]]
function CloudService:Init()
    assert(HttpService.HttpEnabled, "Http requests needs to be enabled for Styngr to work!")
end

--[[
    Startup method
]]
function CloudService:Start()
    -- TODO: Do initial authentication, setup refresh token or cancel out if authentication fails
end

return CloudService