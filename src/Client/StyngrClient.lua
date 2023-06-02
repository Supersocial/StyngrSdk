local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StyngrClient = {}

StyngrClient.__index = StyngrClient

local State = require(ReplicatedStorage.Styngr.State)

local InterfaceService = require(script.Parent.InterfaceService)
local InterfaceStates = require(script.Parent.InterfaceStates)

function StyngrClient.new()
	local self = setmetatable({}, StyngrClient)

	self._interfaceService = InterfaceService:Init()

	ReplicatedStorage.Styngr.NewDataEvent.OnClientEvent:Connect(function(type, data)
		assert(typeof(type) == "string")

		assert(data)

		if type == "STREAMS_AVAILABLE" then
			assert(typeof(data) == "number")

			State:update(function(prev)
				prev.streamsAvailable = data

				return prev
			end)
		end
	end)

	return self
end

function StyngrClient:Toggle()
	local closed = State:get().interfaceState == InterfaceStates.CLOSED

	if closed then
		State:update(function(prev)
			prev.interfaceState = InterfaceStates.PLAYER

			return prev
		end)
	else
		State:update(function(prev)
			prev.interfaceState = InterfaceStates.CLOSED

			return prev
		end)
	end
end

function StyngrClient:SetVisible(state)
	State:update(function(prev)
		prev.showButton = state

		return prev
	end)
end

return StyngrClient.new()
