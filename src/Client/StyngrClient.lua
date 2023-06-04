local StarterPlayer = game:GetService("StarterPlayer")
local StyngrClient = {}

local State = require(StarterPlayer.StarterPlayerScripts.Styngr.State)

local InterfaceService = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceService)
local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

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

function StyngrClient:Init()
	InterfaceService:Init()
end

return StyngrClient
