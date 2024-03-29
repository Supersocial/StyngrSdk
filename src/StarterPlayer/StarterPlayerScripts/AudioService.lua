local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local AudioService = {}

local Promise = require(ReplicatedStorage.Styngr.Packages.promise)
local State = require(StarterPlayer.StarterPlayerScripts.Styngr.State)

local ProgressState = require(StarterPlayer.StarterPlayerScripts.Styngr.ProgressState)
local InterfaceStates = require(StarterPlayer.StarterPlayerScripts.Styngr.InterfaceStates)

local SongEvents = ReplicatedStorage.Styngr.SongEvents

function AudioService:_setNowPlaying(nowPlaying)
	State:update(function(prevState)
		prevState.nowPlaying = nowPlaying

		return prevState
	end)
end

function AudioService:PlayPause()
	if not self._audio then
		return true
	end

	if self._audio.IsPlaying then
		self._audio:Pause()
		return true
	else
		self._audio:Resume()
		return false
	end
end

function AudioService:Stop()
	if not self._audio then
		return
	end

	self._audio:Stop()
	self:_setNowPlaying(nil)
end

function AudioService:CanSkip()
	if not self._audio then
		return true
	end

	if self._audio.TimePosition < 30 then
		return false
	end

	return true
end

function AudioService:PlaySound(track)
	ContentProvider:RegisterSessionEncryptedAsset(track.assetId, track.encryptionKey)

	if not self._audio then
		self._audio = Instance.new("Sound", workspace)
		self._audio.Looped = false

		self._audio.Paused:Connect(function()
			SongEvents:FireServer("PAUSED")
		end)

		self._audio.Resumed:Connect(function()
			SongEvents:FireServer("RESUMED")
		end)

		self._audio.Ended:Connect(function()
			SongEvents:FireServer("ENDED")

			self:_setNowPlaying(nil)

			local nextTrack = ReplicatedStorage.Styngr.RequestNextTrack:InvokeServer()

			if not nextTrack then
				State:update(function(prev)
					if prev.interfaceState == InterfaceStates.PLAYER then
						prev.interfaceState = InterfaceStates.PLAYLIST
					end

					return prev
				end)
				return
			end

			self:PlaySound(nextTrack)
		end)

		self._audio.Played:Connect(function()
			SongEvents:FireServer("PLAYED")
		end)

		RunService.RenderStepped:Connect(function()
			ProgressState:set(math.floor(self._audio.TimePosition / self._audio.TimeLength * 1000) / 1000)
		end)
	end

	if self._audio.IsPlaying then
		self:Stop()
	end

	self._audio.SoundId = track.assetId

	if self._audio.IsLoaded then
		self._audio:Play()
	else
		Promise.fromEvent(self._audio.Loaded)
			:andThen(function()
				self._audio:Play()
			end)
			:await()
	end

	local artists = table.concat(track.artistNames, ", ")

	self:_setNowPlaying({
		playlistId = track.playlistId,
		artists = artists,
		title = track.title,
	})
end

return AudioService
