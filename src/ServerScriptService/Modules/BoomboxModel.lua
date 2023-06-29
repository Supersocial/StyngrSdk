local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)
local Computed = Fusion.Computed
local Value = Fusion.Value

local BoomboxModel = {}
BoomboxModel.__index = BoomboxModel

function BoomboxModel.new(textureId: string, owner: Player)
	local self = setmetatable({}, BoomboxModel)

	self._owner = owner
	self._asset = self:_makeAsset(textureId)
	self._connections = {}

	self._visible = false

	table.insert(self._connections, owner.CharacterAdded:Connect(function()
		if (not self._visible) then return end
		task.wait(0.5)

		self:Show()
	end))

	table.insert(self._connections, owner.CharacterRemoving:Connect(function()
		self:Hide(true)
	end))

	return self
end

function BoomboxModel:Show()
	self._visible = true

	local character = self._owner.Character

	local gripAttachment = character:FindFirstChild("RightGripAttachment", true)
	self._asset.CFrame = gripAttachment.WorldCFrame
	self._asset.BallSocketConstraint.Attachment1 = gripAttachment

	self._asset.Parent = character
end

function BoomboxModel:Hide(dontSetFlag: boolean)
	if (dontSetFlag == nil) then
		self._visible = false
	end

	self._asset.Parent = nil
end

function BoomboxModel:Destroy()
	if (self._asset) then
		self._asset:Destroy()
	end

	for _, connection in self._connections do
		connection:Disconnect()
	end
end

function BoomboxModel:_makeAsset(textureId: string)
	local boombox = Instance.new("Part")
	boombox.Name = "BoomboxModel"
	boombox.Size = Vector3.new(2.2, 1.2, 0.5)
	boombox.CanCollide = false
	boombox.Massless = true

	local attachment = Instance.new("Attachment")
	attachment.Parent = boombox
	attachment.CFrame = CFrame.new(0, boombox.Size.Y / 2, 0) * CFrame.Angles(0, math.rad(65), 0)
	
	local socket = Instance.new("BallSocketConstraint")
	socket.LimitsEnabled = true
	socket.UpperAngle = 20
	socket.Restitution = 1
	socket.Attachment0 = attachment
	socket.Parent = boombox
	socket.MaxFrictionTorque = 15

	local mesh = Instance.new("SpecialMesh")
	mesh.Parent = boombox
	mesh.MeshId = "rbxassetid://13894568565"
	mesh.TextureId = textureId
	mesh.Scale = Vector3.new(0.05, 0.05, 0.05)

	return boombox
end

return BoomboxModel
