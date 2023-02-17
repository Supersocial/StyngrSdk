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
	API_ID = "",
	API_SERVER = "https://tst.api.styngr.com/api/sdk/",
}

--[[
    Handles requesting a new token if there's none or if the current one is expired
]]
local function getToken()
	return Promise.new(function(resolve, reject) end)
end

--[[
    Wraps around every call to external API, ensures token is refreshed and handles errors in a graceful-ish matter
]]
function CloudService:Call(endpoint, method)
	assert(endpoint and typeof(endpoint) == "string" and method and typeof(method) == "string")

	return getToken():andThen(function(token)
		return Promise.new(function(resolve, reject)
			local request = {
				Url = ENVIRONMENT_VARIABLES.API_SERVER .. endpoint,
				Method = method,
				Headers = {
					Authorization = "Bearer " .. token,
					Accept = "application/json",
				},
			}

			local ok, result = pcall(HttpService.RequestAsync, HttpService, request)

			if ok then
				resolve(result)
			else
				reject(result)
			end
		end)
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
