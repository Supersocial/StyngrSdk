local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)
local State = require(ReplicatedStorage.Styngr.State)
local AudioService = require(StarterPlayer.StarterPlayerScripts.Styngr.AudioService)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local function PlaylistItem(props)
	return New("Frame")({
		Name = "Playlist",
		BackgroundColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.fromScale(1, 0.214),

		[Children] = {
			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0.167, 0),
			}),

			New("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0.133, 0),
				PaddingLeft = UDim.new(0.0267, 0),
				PaddingRight = UDim.new(0.0267, 0),
				PaddingTop = UDim.new(0.1, 0),
			}),

			New("Frame")({
				Name = "Content",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.914, 1),

				[Children] = {
					New("TextLabel")({
						Name = "Title",
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Medium,
							Enum.FontStyle.Normal
						),
						Text = props.Title,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextSize = 14,
						TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.5),
					}),

					New("UIListLayout")({
						Name = "UIListLayout",
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					New("TextLabel")({
						Name = "Tracks",
						FontFace = Font.new(
							"rbxasset://fonts/families/GothamSSm.json",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						Text = props.TrackCount .. " Songs",
						TextColor3 = Color3.fromRGB(170, 170, 170),
						TextScaled = true,
						TextSize = 14,
						TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.417),
					}),
				},
			}),

			New("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			New("TextButton")({
				Name = "PlayButton",
				Text = "",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.fromScale(0.086, 1),

				[OnEvent("Activated")] = props.PlayHandler,

				[Children] = {
					New("UIAspectRatioConstraint")({
						Name = "UIAspectRatioConstraint",
					}),

					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(1, 0),
					}),

					New("ImageLabel")({
						Name = "ArrowIcon",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 0.5),
						BackgroundTransparency = 1,
						Image = "rbxassetid://13548540206",

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

local function Playlist()
	local Playlists = Computed(function()
		local playlists = State:get().playlists

		local items = {}

		for _, playlist in playlists do
			table.insert(
				items,
				PlaylistItem({
					["Title"] = playlist.title,
					["TrackCount"] = playlist.trackCount,
					PlayHandler = function()
						local nowPlaying = State:get().nowPlaying

						if nowPlaying and nowPlaying.playlistId == playlist.id then
							State:update(function(prev)
								prev.interfaceState = InterfaceStates.PLAYER

								return prev
							end)
							return
						end

						local track = ReplicatedStorage.Styngr.StartPlaylistSession:InvokeServer(playlist.id)

						if not track then
							AudioService:Stop()
							return
						end

						AudioService:PlaySound(track)

						State:update(function(prev)
							prev.interfaceState = InterfaceStates.PLAYER

							return prev
						end)
					end,
				})
			)
		end

		return items
	end)

	return New("Frame")({
		Name = "Playlist",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

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
						PaddingBottom = UDim.new(0.0205, 0),
						PaddingLeft = UDim.new(0.015, 0),
						PaddingRight = UDim.new(0.015, 0),
						PaddingTop = UDim.new(0.0205, 0),
					}),

					New("ScrollingFrame")({
						Name = "ScrollingFrame",
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(),
						Active = true,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),

						[Children] = {
							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0.0214, 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							Playlists,
						},
					}),
				},
			}),
		},
	})
end

return Playlist
