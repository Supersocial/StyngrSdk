local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local Value = Fusion.Value

local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local State = Value({
	interfaceState = InterfaceStates.CLOSED,
	showButton = true,
	playlists = {},
	streamsAvailable = 0,
})

function State:update(callback)
	local newValue = callback(State:get())

	assert(newValue and typeof(newValue) == "table")

	return State:set(newValue)
end

function State:setInterfaceState(interfaceState)
	local state = self:get()

	state.interfaceState = interfaceState

	return self:set(state)
end

return State
