local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)

--[[
    CloudService
    Serves as a middleware between HTTPService and StyngrService, handles things like token storage, refreshing.
]]
local CloudService = {}

CloudService.__index = CloudService

type CloudServiceConstructor = {
	apiKey: string,
	appId: string,
	apiServer: string,
}

--[[
	Creates a new CloudService instance
]]
function CloudService.new(input: CloudServiceConstructor)
	assert(
		input and input.apiKey and input.appId and input.apiServer,
		"Please ensure all CloudService constructor params are filled out!"
	)

	local self = {
		_tokens = {},
		_apiKey = input.apiKey,
		_appId = input.appId,
		_apiServer = input.apiServer,
	}

	setmetatable(self, CloudService)

	return self
end

--[[
	Deletes the cached token, only intended to be used when the player joins to free up memory...
]]
function CloudService:DeleteToken(userId: number)
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
    (INTERNAL METHOD)
	Makes a POST call to the external API generating a new token for the specified user
	@returns an object with the new token inside
]]
function CloudService:CreateToken(userId: number)
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
    (INTERNAL METHOD)
]]
function CloudService:ReadToken(userId: number)
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

--[[
	Gets or creates a new token for the specified userId
]]
function CloudService:GetToken(userId: number)
	assert(
		self._tokens,
		"Please make sure that you have set up a new CloudService instance before calling this method!"
	)

	assert(typeof(userId) == "number", "Please pass in a valid userId!")

	return Promise.new(function(resolve, reject)
		self:ReadToken(userId):andThen(resolve, function()
			self:CreateToken(userId):andThen(resolve, reject)
		end)
	end)
end

--[[
    Wraps around every call to external API, ensures token is refreshed and handles errors in a graceful-ish matter
]]
function CloudService:Call(token: string, endpoint: string, method: "GET" | "POST" | "PATCH", body: table?)
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
