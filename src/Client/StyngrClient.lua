local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StyngrClient = {}

StyngrClient.__index = StyngrClient

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local Value = Fusion.Value

local InterfaceService = require(script.Parent.InterfaceService)
local InterfaceStates = require(script.Parent.InterfaceStates)

function StyngrClient.new()
	local self = setmetatable({}, StyngrClient)

	self._state = Value(InterfaceStates.CLOSED)
	self._showButton = Value(true)
	self._interfaceService = InterfaceService:Init(self._state, self._showButton)

	return self
end

function StyngrClient:Toggle()
	local closed = self._state:get() == InterfaceStates.CLOSED

	if closed then
		-- TODO: Add conditional to open X depending on Y, right now we always open the player though
		self._state:set(InterfaceStates.PLAYER)
	else
		self._state:set(InterfaceStates.CLOSED)
	end
end

function StyngrClient:SetVisible(state)
	self._showButton:set(state)
end

return StyngrClient.new()
