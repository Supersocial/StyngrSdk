local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local State = require(ReplicatedStorage.Styngr.State)
local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

--[[
	SMALL -> 50
MEDIUM -> 100
LARGE -> 200
]]

local function Options()
	return New("Frame")({
		Name = "Options",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.75),

		[Children] = {
			New("UIListLayout")({
				Name = "UIListLayout",
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("Frame")({
				Name = "Small",
				BackgroundColor3 = Color3.fromRGB(34, 34, 34),
				Size = UDim2.fromScale(1, 0.333),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0.156, 0),
					}),

					New("TextLabel")({
						Name = "Streams",
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = "50 Streams",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.669, 0.462),
					}),

					New("TextButton")({
						Name = "Purchase",
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14,
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromScale(0.331, 1),

						[OnEvent("Activated")] = function()
							MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1549281250)
						end,

						[Children] = {
							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0.231, 0),
							}),

							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0.1, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							New("TextLabel")({
								Name = "Price",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								Text = "35",
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextScaled = true,
								TextSize = 14,
								TextWrapped = true,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.25, 0.857),
							}),

							New("UIPadding")({
								Name = "UIPadding",
								PaddingBottom = UDim.new(0.231, 0),
								PaddingTop = UDim.new(0.231, 0),
							}),

							New("ImageLabel")({
								Name = "Robux",
								Image = "rbxassetid://13588144310",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.fromScale(1, 1),

								[Children] = {
									New("UIAspectRatioConstraint")({
										Name = "UIAspectRatioConstraint",
									}),
								},
							}),
						},
					}),

					New("UIPadding")({
						Name = "UIPadding",
						PaddingBottom = UDim.new(0.0938, 0),
						PaddingLeft = UDim.new(0.016, 0),
						PaddingRight = UDim.new(0.016, 0),
						PaddingTop = UDim.new(0.094, 0),
					}),

					New("UIListLayout")({
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
				},
			}),

			New("Frame")({
				Name = "Medium",
				BackgroundColor3 = Color3.fromRGB(34, 34, 34),
				Size = UDim2.fromScale(1, 0.333),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0.156, 0),
					}),

					New("TextLabel")({
						Name = "Streams",
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = "100 Streams",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.669, 0.462),
					}),

					New("TextButton")({
						Name = "Purchase",
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14,
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromScale(0.331, 1),

						[OnEvent("Activated")] = function()
							MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1549281380)
						end,

						[Children] = {
							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0.231, 0),
							}),

							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0.1, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							New("TextLabel")({
								Name = "Price",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								Text = "35",
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextScaled = true,
								TextSize = 14,
								TextWrapped = true,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.25, 0.857),
							}),

							New("UIPadding")({
								Name = "UIPadding",
								PaddingBottom = UDim.new(0.231, 0),
								PaddingTop = UDim.new(0.231, 0),
							}),

							New("ImageLabel")({
								Name = "Robux",
								Image = "rbxassetid://13588144310",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.fromScale(1, 1),

								[Children] = {
									New("UIAspectRatioConstraint")({
										Name = "UIAspectRatioConstraint",
									}),
								},
							}),
						},
					}),

					New("UIPadding")({
						Name = "UIPadding",
						PaddingBottom = UDim.new(0.0938, 0),
						PaddingLeft = UDim.new(0.016, 0),
						PaddingRight = UDim.new(0.016, 0),
						PaddingTop = UDim.new(0.094, 0),
					}),

					New("UIListLayout")({
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
				},
			}),

			New("Frame")({
				Name = "Large",
				BackgroundColor3 = Color3.fromRGB(34, 34, 34),
				Size = UDim2.fromScale(1, 0.333),

				[Children] = {
					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0.156, 0),
					}),

					New("TextLabel")({
						Name = "Streams",
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = "200 Streams",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.669, 0.462),
					}),

					New("TextButton")({
						Name = "Purchase",
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14,
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.fromScale(0.331, 1),

						[OnEvent("Activated")] = function()
							MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1549281432)
						end,

						[Children] = {
							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0.231, 0),
							}),

							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0.1, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							New("TextLabel")({
								Name = "Price",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								Text = "35",
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextScaled = true,
								TextSize = 14,
								TextWrapped = true,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.25, 0.857),
							}),

							New("UIPadding")({
								Name = "UIPadding",
								PaddingBottom = UDim.new(0.231, 0),
								PaddingTop = UDim.new(0.231, 0),
							}),

							New("ImageLabel")({
								Name = "Robux",
								Image = "rbxassetid://13588144310",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Size = UDim2.fromScale(1, 1),

								[Children] = {
									New("UIAspectRatioConstraint")({
										Name = "UIAspectRatioConstraint",
									}),
								},
							}),
						},
					}),

					New("UIPadding")({
						Name = "UIPadding",
						PaddingBottom = UDim.new(0.0938, 0),
						PaddingLeft = UDim.new(0.016, 0),
						PaddingRight = UDim.new(0.016, 0),
						PaddingTop = UDim.new(0.094, 0),
					}),

					New("UIListLayout")({
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
				},
			}),
		},
	})
end

local function Breadcrumb()
	return New("Frame")({
		Name = "Breadcrumb",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.2),

		[Children] = {
			New("TextLabel")({
				Name = "Title",
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Text = "Stream Packs",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				TextWrapped = true,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 0.5),
			}),

			New("ImageButton")({
				Name = "Left",
				Image = "rbxassetid://13588150018",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 0.5),

				[OnEvent("Activated")] = function()
					State:setInterfaceState(InterfaceStates.PLAYER)
				end,

				[Children] = {
					New("UIAspectRatioConstraint")({
						Name = "UIAspectRatioConstraint",
					}),
				},
			}),
		},
	})
end

local function Streams()
	local streamsAvailable = Computed(function()
		return State:get().streamsAvailable .. " streams left"
	end)

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
								Text = streamsAvailable,
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
			New("Frame")({
				Name = "Content",
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.859),

				[Children] = {
					New("UIPadding")({
						Name = "UIPadding",
						PaddingBottom = UDim.new(0.0411, 0),
						PaddingLeft = UDim.new(0.03, 0),
						PaddingRight = UDim.new(0.03, 0),
						PaddingTop = UDim.new(0.082, 0),
					}),

					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0.05, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Breadcrumb(),
					Options(),
				},
			}),
		},
	})
end

return Streams
