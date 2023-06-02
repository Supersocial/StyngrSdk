local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local State = require(ReplicatedStorage.Styngr.State)
local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed

local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local function Header()
	local title = Computed(function()
		local nowPlaying = State:get().nowPlaying

		if not nowPlaying then
			return ""
		end

		return nowPlaying.title
	end)

	local artists = Computed(function()
		local nowPlaying = State:get().nowPlaying

		if not nowPlaying then
			return ""
		end

		return nowPlaying.artists
	end)

	local playPauseImage = Computed(function()
		local nowPlaying = State:get().nowPlaying

		if not nowPlaying then
			return "rbxassetid://13551674540"
		end

		if nowPlaying.paused then
			return "rbxassetid://13551674641"
		end

		return "rbxassetid://13171794794"
	end)

	return New("Frame")({
		Name = "Header",
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 0.556),

		[Children] = {
			New("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0.0263, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			New("TextButton")({
				Name = "Menu",
				AutoButtonColor = true,
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.85,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(1, 1),

				[OnEvent("Activated")] = function()
					local playlists = ReplicatedStorage.Styngr.GetPlaylists:InvokeServer()

					State:update(function(prev)
						prev.playlists = playlists
						prev.interfaceState = InterfaceStates.PLAYLIST

						return prev
					end)
				end,

				[Children] = {
					New("UIAspectRatioConstraint")({}),
					New("UICorner")({
						CornerRadius = UDim.new(1, 0),
					}),
					New("ImageLabel")({
						Name = "Hamburger",
						Image = "rbxassetid://13171794624",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.467, 1),

						[Children] = {
							New("UIAspectRatioConstraint")({
								AspectRatio = 1.2,
							}),
						},
					}),
				},
			}),
			New("Frame")({
				Name = "Content",
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.768, 0.933),

				[Children] = {
					New("UIListLayout")({
						Padding = UDim.new(0.0958, 0),
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					New("Frame")({
						Name = "Song",
						AnchorPoint = Vector2.new(0, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.821, 1),

						[Children] = {
							New("UIListLayout")({
								Padding = UDim.new(0.107, 0),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Bottom,
							}),
							New("TextLabel")({
								Name = "Playlist",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Regular,
									Enum.FontStyle.Normal
								),
								Text = artists,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextScaled = true,
								TextYAlignment = Enum.TextYAlignment.Top,
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 0.286),
							}),
							New("TextLabel")({
								Name = "Title",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								Text = title,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextScaled = true,
								TextYAlignment = Enum.TextYAlignment.Top,
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 0.357),
							}),
							New("CanvasGroup")({
								Name = "Progress",
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 0.7,
								Size = UDim2.fromScale(1, 0.143),

								[Children] = {
									New("UICorner")({
										CornerRadius = UDim.new(0.5, 0),
									}),

									New("Frame")({
										Name = "Line",
										BackgroundColor3 = Color3.fromRGB(122, 247, 255),
										Size = UDim2.fromScale(1, 1),
										Position = UDim2.fromScale(-1, 0),
									}),
								},
							}),
						},
					}),
					New("ImageButton")({
						Name = "PlayPause",
						Image = playPauseImage,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 0.643),

						[OnEvent("Activated")] = function()
							if not State:get().nowPlaying then
								return
							end

							State:update(function(prev)
								local nowPlaying = prev.nowPlaying

								if nowPlaying.paused then
									nowPlaying.instance:Resume()
									nowPlaying.paused = false
								else
									nowPlaying.instance:Pause()
									nowPlaying.paused = true
								end

								return prev
							end)
						end,

						[Children] = {
							New("UIAspectRatioConstraint")({
								Name = "UIAspectRatioConstraint",
								AspectRatio = 0.667,
							}),
						},
					}),
				},
			}),
		},
	})
end

return Header
