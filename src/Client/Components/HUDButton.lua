local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local State = require(ReplicatedStorage.Styngr.State)
local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local function HUDButton()
	local closed = Computed(function()
		return State:get().interfaceState == InterfaceStates.CLOSED
	end)

	return New("ImageButton")({
		Name = "HUDButton",
		Active = true,
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Computed(function()
			if closed:get() then
				return Color3.fromRGB(0, 0, 0)
			end

			return Color3.fromRGB(255, 255, 255)
		end),
		BackgroundTransparency = Computed(function()
			if closed:get() then
				return 0.5
			end

			return 0
		end),
		Position = UDim2.fromScale(0.5, 0.991),
		Selectable = false,
		Size = UDim2.fromScale(1, 0.083),

		[OnEvent("Activated")] = function()
			State:update(function(prev)
				if prev.interfaceState == InterfaceStates.CLOSED then
					if prev.nowPlaying then
						prev.interfaceState = InterfaceStates.PLAYER
					else
						local result = ReplicatedStorage.Styngr.GetPlaylists:InvokeServer()

						prev.playlists = result.playlists
						prev.interfaceState = InterfaceStates.PLAYLIST
					end
				else
					prev.interfaceState = InterfaceStates.CLOSED
				end

				return prev
			end)
		end,

		[Children] = {
			New("UIAspectRatioConstraint")({
				Name = "UIAspectRatioConstraint",
			}),

			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(1, 0),
			}),

			New("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0.233, 0),
				PaddingLeft = UDim.new(0.233, 0),
				PaddingRight = UDim.new(0.233, 0),
				PaddingTop = UDim.new(0.233, 0),
			}),

			New("ImageLabel")({
				Visible = Computed(function()
					return closed:get()
				end),
				Name = "Music",
				Image = "rbxassetid://13219928845",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
			}),

			New("ImageLabel")({
				Visible = Computed(function()
					return not closed:get()
				end),
				Name = "Cross",
				Image = "rbxassetid://13220000054",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
			}),
		},
	})
end

return HUDButton
