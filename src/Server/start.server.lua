local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
	Fill out with example
]]

local CloudService = require(script.Parent.CloudService)
local StyngrService = require(script.Parent.StyngrService)

local cloudService = CloudService.new(
	"STYNAPP-kSzCNaZFzonvAs3rALos4Dzw2TxV0K",
	"591711ce-0869-469f-9646-35bff6af8cdc",
	"https://tst.api.styngr.com/api/sdk/"
)

local styngrService = StyngrService.new(cloudService)

local TestEZ = require(ReplicatedStorage.Styngr.DevPackages.testez)

TestEZ.TestBootstrap:run({ script.Parent })

Players.PlayerRemoving:Connect(function(player)
	cloudService:DeleteToken(player.UserId)
end)

do
	local _, result = styngrService:GetPlaylists(3):await()

	print(result)
end
