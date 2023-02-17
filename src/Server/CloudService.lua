local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)

--[[
    CloudService
    Serves as a middleware between HTTPService and StyngrService, handles things like token storage, refreshing.
]]
local CloudService = {}

CloudService.__index = CloudService

function CloudService.new(apiKey: string, appId: string, apiServer: string)
	local self = {
		_tokens = {},
		_apiKey = apiKey,
		_appId = appId,
		_apiServer = apiServer,
	}

	setmetatable(self, CloudService)

	return self
end

--[[
	Makes a POST call to the external API generating a new token for the specified user
	@returns an object with the new token inside
]]
function CloudService:CreateSDKToken(userId: number)
	assert(
		self._tokens,
		"Please make sure that you have set up a new CloudService instance before calling this method!"
	)

	assert(typeof(userId) == "number", "Please pass in a valid userId!")

	return Promise.new(function(resolve, reject)
		local body = {
			appId = self._appId,
			deviceId = "",
			expiresIn = "PT1H",
			userId = tostring(userId),
		}

		local request = {
			Url = self._apiServer .. "/tokens",
			Method = "POST",
			Headers = {
				["x-api-token"] = self._apiKey,
				Accept = "application/json",
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(body),
		}

		local ok, result = pcall(HttpService.RequestAsync, HttpService, request)

		if ok then
			if result.Success then
				resolve(HttpService:JSONDecode(result.Body))
			else
				reject(result)
			end
		else
			reject(result)
		end
	end)
end

--[[
    Handles requesting a new token if there's none or if the current one is expired
]]
function CloudService:GetToken(userId: number)
	assert(
		self._tokens,
		"Please make sure that you have set up a new CloudService instance before calling this method!"
	)

	assert(typeof(userId) == "number", "Please pass in a valid userId!")

	return Promise.new(function(resolve, reject)
		local existingToken = self._tokens[userId]

		-- TODO: Token expires after a certain amount of time, we need to handle that - but the current solution would involve parsing the JWT token which I don't feel like getting into right now...
		if existingToken then
			resolve(existingToken)
		else
			self:CreateSDKToken(userId)
				:andThen(function(tokenResponse)
					self._tokens[userId] = tokenResponse.token

					resolve(tokenResponse.token)
				end)
				:catch(reject)
		end
	end)
end

--[[
    Wraps around every call to external API, ensures token is refreshed and handles errors in a graceful-ish matter
]]
function CloudService:Call(token, endpoint, method, body)
	assert(token and endpoint and method)

	return Promise.new(function(resolve, reject)
		local request = {
			Url = self._apiServer .. endpoint,
			Method = method,
			Headers = {
				Authorization = "Bearer " .. token,
				Accept = "application/json",
				["Content-Type"] = "application/json",
			},
		}

		if body then
			request.Body = HttpService:JSONEncode(body)
		end

		local ok, result = pcall(HttpService.RequestAsync, HttpService, request)

		if ok then
			if result.Success == true then
				resolve(result)
			else
				reject(result)
			end
		else
			reject(result)
		end
	end)
end

return CloudService
