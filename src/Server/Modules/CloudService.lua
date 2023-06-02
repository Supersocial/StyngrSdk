--[=[
	@class CloudService

	Middleware for external API calls
]=]

local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local Types = require(ServerScriptService.Styngr.Types)

local CloudService = {}

CloudService.__index = CloudService

--[=[
	Creates a new CloudService instance with the specified configuration

	@param inputConfiguration { apiKey: string, appId: string, apiServer: string? } -- Configuration
]=]
function CloudService.new(inputConfiguration: Types.CloudServiceConfiguration)
	assert(
		inputConfiguration
			and inputConfiguration.apiKey
			and typeof(inputConfiguration.apiKey) == "string"
			and inputConfiguration.appId
			and typeof(inputConfiguration.appId) == "string"
			and inputConfiguration.apiServer
			and typeof(inputConfiguration.apiServer) == "string",
		"Please ensure all CloudService constructor params are filled out!"
	)

	local self = {
		_tokens = {},
		_configuration = inputConfiguration,
		_bundles = {
			"SUBSCRIPTION_RADIO_BUNDLE_SMALL",
			"SUBSCRIPTION_RADIO_BUNDLE_MEDIUM",
			"SUBSCRIPTION_RADIO_BUNDLE_LARGE",
			"SUBSCRIPTION_RADIO_BUNDLE_FREE",
		},
	}

	setmetatable(self, CloudService)

	return self
end

--[[
	Deletes token from cache
]]
function CloudService:_deleteToken(userId: number)
	assert(
		self._tokens,
		"Please make sure that you have set up a new CloudService instance before calling this method!"
	)

	assert(typeof(userId) == "number", "Please pass in a valid userId!")

	if self._tokens[userId] then
		self._tokens[userId] = nil
	end
end

--[[
	Makes a HttpService call to the external API that returns a token for the specified userId
]]
function CloudService:_createToken(userId: number, countryCode: string)
	assert(
		self._tokens,
		"Please make sure that you have set up a new CloudService instance before calling this method!"
	)

	assert(typeof(userId) == "number", "Please pass in a valid userId!")

	assert(typeof(countryCode) == "string", "Please pass in a valid countryCode!")

	return Promise.new(function(resolve, reject)
		local body = {
			appId = self._configuration.appId,
			deviceId = "",
			expiresIn = "PT3H",
			userId = tostring(userId),
			countryCode = countryCode,
		}

		local request = {
			Url = self._configuration.apiServer .. "/v2/sdk/tokens",
			Method = "POST",
			Headers = {
				["x-api-token"] = self._configuration.apiKey,
				Accept = "application/json",
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(body),
		}

		local ok, result = pcall(HttpService.RequestAsync, HttpService, request)

		if ok then
			if result.Success then
				local resultBody = HttpService:JSONDecode(result.Body)

				if resultBody["token"] then
					self._tokens[userId] = resultBody["token"]
					resolve(resultBody["token"])
				else
					reject(result)
				end
			else
				reject(result)
			end
		else
			reject(result)
		end
	end)
end

--[[
	Reads token for the specified userId from cache
]]
function CloudService:_readToken(userId: number)
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
			reject()
		end
	end)
end

--[=[
	Gets or creates token for the specified player

	@param player Player -- User to get or create token for
]=]
function CloudService:GetToken(player: Player)
	assert(
		self._tokens,
		"Please make sure that you have set up a new CloudService instance before calling this method!"
	)

	assert(player, "Please pass in a valid player!")

	return Promise.new(function(resolve, reject)
		self:_readToken(player.UserId):andThen(resolve, function()
			local result, countryCode =
				pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, player)

			if not result then
				reject("Country code could not be gotten for player, aborting flow.")
			end

			self:_createToken(player.UserId, countryCode):andThen(resolve, reject)
		end)
	end)
end

--[=[
	Wraps around the default `HttpService:Request()` method to include headers and additional metadata for the API request

	@param token string -- API token to authenticate request with
	@param endpoint string -- The endpoint to call externally
	@param method string -- The method to use (GET, POST, PATCH, DELETE, PUT)
	@param body table? -- A table containing any data you want to follow along with your request
]=]
function CloudService:Call(token, endpoint, method, body)
	assert(
		token
			and typeof(token) == "string"
			and endpoint
			and typeof(endpoint) == "string"
			and method
			and typeof(method) == "string",
		"Please ensure all parameters have been passed in and are of correct type!"
	)

	method = string.upper(method)

	assert(
		method == "POST" or method == "GET" or method == "PUT" or method == "PATCH" or method == "DELETE",
		"Invalid HTTP method."
	)

	return Promise.new(function(resolve, reject)
		local request = {
			Url = self._configuration.apiServer .. endpoint,
			Method = method,
			Headers = {
				Authorization = "Bearer " .. token,
				Accept = "application/json",
				["Content-Type"] = "application/json",
			},
		}

		if body then
			request.Body = HttpService:JSONEncode(body)
		else
			if method == "POST" then
				request.Body = ""
			end
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
