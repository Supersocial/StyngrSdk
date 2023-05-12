local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children

local function Playlist(props)
	return New("Frame")({
		Name = "Playlist",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		-- AnchorPoint = Vector2.new(0.5, 0.5),
		-- BackgroundColor3 = Color3.fromRGB(17, 17, 17),
		-- BackgroundTransparency = 0.1,
		-- Position = UDim2.fromScale(0.5, 0.5),

		[Children] = {
			New("Frame")({
				Name = "Header",
				BackgroundColor3 = Color3.fromRGB(17, 17, 17),
				Size = UDim2.fromScale(1, 0.141),

				[Children] = {
					New("UIPadding")({
						Name = "UIPadding",
						PaddingBottom = UDim.new(0.125, 0),
						PaddingLeft = UDim.new(0.025, 0),
						PaddingRight = UDim.new(0.015, 0),
						PaddingTop = UDim.new(0.125, 0),
					}),

					New("TextLabel")({
						Name = "Title",
						FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
						Text = "Boombox",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.349, 1),
					}),

					New("Frame")({
						Name = "Streams",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.9,
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromScale(0.417, 1),

						[Children] = {
							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0.333, 0),
							}),

							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0.0278, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							New("UIPadding")({
								Name = "UIPadding",
								PaddingBottom = UDim.new(0.222, 0),
								PaddingLeft = UDim.new(0.05, 0),
								PaddingRight = UDim.new(0.05, 0),
								PaddingTop = UDim.new(0.222, 0),
							}),

							New("TextLabel")({
								Name = "StreamsLeft",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								Text = "12 Streams Left",
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextScaled = true,
								TextSize = 14,
								TextWrapped = true,
								TextXAlignment = Enum.TextXAlignment.Right,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.847, 1),
							}),

							New("ImageLabel")({
								Name = "Icon",
								Image = "rbxassetid://13172323563",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
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
			}),
		},
	})
end

return Playlist
