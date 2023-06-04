local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed

local AudioService = require(StarterPlayer.StarterPlayerScripts.Styngr.AudioService)
local State = require(ReplicatedStorage.Styngr.State)
local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local function Footer()
	return New("Frame")({
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.296),

		[Children] = {
			New("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0.25, 0),
				PaddingLeft = UDim.new(0.021, 0),
				PaddingRight = UDim.new(0.021, 0),
				PaddingTop = UDim.new(0.25, 0),
			}),

			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 6),
			}),

			New("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("Frame")({
				Name = "Right",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = Computed(function()
					local nowPlaying = State:get().nowPlaying

					if not nowPlaying then
						return false
					end

					return true
				end),

				[Children] = {
					New("TextButton")({
						Name = "Next",
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = "Next",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 32,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Right,
						AnchorPoint = Vector2.new(1, 0),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(27, 42, 53),
						Position = UDim2.fromScale(0.879, 0),
						Size = UDim2.fromScale(0.0024, 1),

						[OnEvent("Activated")] = function()
							if not AudioService:CanSkip() then
								return
							end

							local track = ReplicatedStorage.Styngr.SkipTrack:InvokeServer()

							if not track then
								AudioService:Stop()

								State:update(function(prev)
									prev.interfaceState = InterfaceStates.PLAYLIST

									return prev
								end)

								return
							end

							AudioService:PlaySound(track)
						end,
					}),

					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0, 9),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					New("ImageLabel")({
						Name = "Icon",
						Image = "rbxassetid://13172323318",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = UDim2.fromScale(1, 1),

						[Children] = {
							New("UIAspectRatioConstraint")({
								Name = "UIAspectRatioConstraint",
							}),
						},
					}),
				},
			}),
		},
	})
end

return Footer
