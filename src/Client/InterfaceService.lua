local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local InterfaceService = {}

local State = require(StarterPlayer.StarterPlayerScripts.Styngr.State)

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local Components = StarterPlayer.StarterPlayerScripts.Styngr.Components

local HUDButton = require(Components.HUDButton)
local Player = require(Components.Player)
local Playlist = require(Components.Playlist)

local function StyngrFrame()
	local children = Computed(function()
		local currentWindow = State:get().interfaceState

		if currentWindow == InterfaceStates.CLOSED then
			return {}
		end

		if currentWindow == InterfaceStates.PLAYER then
			return {
				Player(),
				New("UICorner")({
					CornerRadius = UDim.new(0.149, 0),
				}),
				New("UIPadding")({
					PaddingBottom = UDim.new(0.075, 0),
					PaddingLeft = UDim.new(0.025, 0),
					PaddingRight = UDim.new(0.025, 0),
					PaddingTop = UDim.new(0.119, 0),
				}),
				New("UISizeConstraint")({
					MinSize = Vector2.new(400, 134),
				}),
			}
		end

		if currentWindow == InterfaceStates.PLAYLIST then
			return {
				Playlist(),
				New("UISizeConstraint")({
					MinSize = Vector2.new(200, 170),
				}),

				New("UICorner")({
					CornerRadius = UDim.new(0.0588, 0),
				}),
			}
		end

		return {}
	end)

	return New("CanvasGroup")({
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 0.875),

		Size = Computed(function()
			local currentWindow = State:get().interfaceState

			if currentWindow == InterfaceStates.PLAYER then
				return UDim2.fromScale(0.313, 0.186)
			end

			if currentWindow == InterfaceStates.PLAYLIST then
				return UDim2.fromScale(0.313, 0.473)
			end

			return UDim2.fromScale(0, 0)
		end),
		BackgroundColor3 = Computed(function()
			local currentWindow = State:get().interfaceState

			if currentWindow == InterfaceStates.PLAYER then
				return Color3.fromRGB(34, 34, 34)
			end

			if currentWindow == InterfaceStates.PLAYLIST then
				return Color3.fromRGB(17, 17, 17)
			end

			return Color3.new()
		end),
		BackgroundTransparency = Computed(function()
			local currentWindow = State:get().interfaceState

			if currentWindow == InterfaceStates.PLAYER then
				return 0
			end

			if currentWindow == InterfaceStates.PLAYLIST then
				return 0.1
			end

			return 1
		end),

		Visible = Computed(function()
			if State:get().interfaceState == InterfaceStates.CLOSED then
				return false
			end

			return true
		end),

		[Children] = children,
	})
end

function InterfaceService:Init()
	local children = Computed(function()
		if State:get().showButton then
			return {
				HUDButton(),
				StyngrFrame(),
			}
		end

		return {
			StyngrFrame(),
		}
	end)

	New("ScreenGui")({
		Name = "StyngrUI",
		Parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"),

		[Children] = children,
	})
end

return InterfaceService
