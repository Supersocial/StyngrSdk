local Playlists = {}
local ContentProvider = game:GetService("ContentProvider")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local Styngr = PlayerGui:WaitForChild("Styngr")
local PlaylistSelectorButton = Styngr.PlaylistSelectorButton :: TextButton
local PlaylistSelector = Styngr.PlaylistSelector :: Frame
local ScrollingFrame = PlaylistSelector.ScrollingFrame :: ScrollingFrame
local Template = PlaylistSelector.Template :: Frame

local StyngrPlayer = Styngr.Player

local Info = StyngrPlayer.Info :: Frame
local NowPlaying = Info.NowPlaying :: TextLabel

local ProgressBarContainer = StyngrPlayer.ProgressBarContainer :: Frame
local ProgressLineContainer = ProgressBarContainer.ProgressLineContainer :: Frame
local ProgressLine = ProgressLineContainer.ProgressLine :: Frame

local CurrentTime = ProgressBarContainer.CurrentTime :: TextLabel
local MaxTime = ProgressBarContainer.MaxTime :: TextLabel

local Buttons = StyngrPlayer.Buttons :: Frame
local PlayPauseButton = Buttons.PlayPause :: ImageButton

local progressLineDefaultPosition = ProgressLine.Position
local maxTimeDefaultText = MaxTime.Text
local nowPlayingDefaultText = NowPlaying.Text

local pauseIcon = "rbxassetid://12715246634"
local playIcon = "rbxassetid://12715246836"

local function secondsToMinutesAndSeconds(inputSeconds: number)
	local minutes = math.floor(inputSeconds / 60)
	local formattedMinutes = if minutes < 10 then "0" .. minutes else tostring(minutes)

	local seconds = math.floor(inputSeconds - (minutes * 60))
	local formattedSeconds = if seconds < 10 then "0" .. seconds else tostring(seconds)

	return formattedMinutes .. ":" .. formattedSeconds
end

local function playSound(track)
	ContentProvider:RegisterSessionEncryptedAsset(track.assetId, track.encryptionKey)

	local artists = table.concat(track.artistNames, ", ")

	local sound = Instance.new("Sound", workspace)
	local tween, playPauseButtonConnection

	sound.Looped = false
	sound.SoundId = track.assetId

	sound.Paused:Connect(function()
		if not tween then
			return
		end

		tween:Pause()
	end)

	sound.Resumed:Connect(function()
		PlayPauseButton.Image = pauseIcon

		if not tween then
			return
		end

		tween:Play()
	end)

	sound.Ended:Connect(function()
		sound:Destroy()

		if tween then
			tween:Cancel()
			tween:Destroy()

			ProgressLine.Position = progressLineDefaultPosition
		end

		if playPauseButtonConnection then
			playPauseButtonConnection:Disconnect()
		end

		NowPlaying.Text = nowPlayingDefaultText
		MaxTime.Text = maxTimeDefaultText
		PlayPauseButton.Image = playIcon

		local data = ReplicatedStorage.Styngr.RequestNextTrack:InvokeServer()

		playSound(data)
	end)

	sound.Played:Connect(function()
		NowPlaying.Text = artists .. " - " .. track.title
		PlayPauseButton.Image = pauseIcon
		MaxTime.Text = secondsToMinutesAndSeconds(sound.TimeLength)

		tween = TweenService:Create(
			ProgressLine,
			TweenInfo.new(sound.TimeLength),
			{ Position = UDim2.new({ 0, 0 }, { 0, 0 }) }
		)
		tween:Play()

		playPauseButtonConnection = PlayPauseButton.Activated:Connect(function()
			if sound.IsPaused then
				PlayPauseButton.Image = pauseIcon
				sound:Resume()
			else
				PlayPauseButton.Image = playIcon
				sound:Pause()
			end
		end)
	end)

	if sound.IsLoaded then
		sound:Play()
	else
		Promise.fromEvent(sound.Loaded):andThen(function()
			sound:Play()
		end)
	end
end

function TogglePlaylistSelector()
	local nextState = not PlaylistSelector.Visible

	PlaylistSelector.Visible = nextState
	PlaylistSelectorButton.Text = if nextState then "Hide Playlists" else "Show Playlists"

	if nextState then
		ScrollingFrame:ClearAllChildren()

		local playlists = ReplicatedStorage.Styngr.GetPlaylists:InvokeServer()

		for _, playlist in playlists do
			local Playlist = Template:Clone()

			Playlist.Title.Text = playlist.title
			Playlist.Play.Activated:Connect(function()
				local data = ReplicatedStorage.Styngr.StartPlaylistSession:InvokeServer(playlist.id)

				playSound(data)

				TogglePlaylistSelector()
			end)

			Playlist.Parent = ScrollingFrame
			Playlist.Visible = true
		end
	end
end

PlaylistSelectorButton.Activated:Connect(TogglePlaylistSelector)

return Playlists
