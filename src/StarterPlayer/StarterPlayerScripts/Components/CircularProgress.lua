local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Styngr.Packages.fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local function CircularProgress(props)
	local percentNumber = Computed(function()
		return math.clamp(props.percentage:get() * 3.6, 0, 360)
	end)

	return New("Frame")({
		Name = "Progress",
		AnchorPoint = props.anchorPoint,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = props.position,
		Size = props.size,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		[Children] = {
			New("Frame")({
				Name = "Frame1",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Size = UDim2.fromScale(0.5, 1),

				[Children] = {
					New("ImageLabel")({
						Name = "ImageLabel",
						Image = "rbxassetid://3587367081",
						ImageTransparency = 0,
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.fromScale(2, 1),

						[Children] = {
							New("UIGradient")({
								Name = "UIGradient",
								Rotation = Computed(function()
									return math.clamp(percentNumber:get(), 180, 360)
								end),
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, props.progressColor),
									ColorSequenceKeypoint.new(0.5, props.progressColor),
									ColorSequenceKeypoint.new(0.501, Color3.fromRGB(0, 0, 0)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
								}),
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(0.5, 0),
									NumberSequenceKeypoint.new(0.501, 0.5),
									NumberSequenceKeypoint.new(1, 0.5),
								}),
							}),
						},
					}),
				},
			}),

			New("Frame")({
				Name = "Frame2",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0.5, 1),

				[Children] = {
					New("ImageLabel")({
						Name = "ImageLabel",
						Image = "rbxassetid://3587367081",
						ImageTransparency = 0,
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(-1, 0),
						Size = UDim2.fromScale(2, 1),

						[Children] = {
							New("UIGradient")({
								Name = "UIGradient",
								Rotation = Computed(function()
									return math.clamp(percentNumber:get(), 0, 180)
								end),
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, props.progressColor),
									ColorSequenceKeypoint.new(0.5, props.progressColor),
									ColorSequenceKeypoint.new(0.501, Color3.fromRGB(0, 0, 0)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
								}),
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(0.5, 0),
									NumberSequenceKeypoint.new(0.501, 0.5),
									NumberSequenceKeypoint.new(1, 0.5),
								}),
							}),
						},
					}),
				},
			}),
		},
	})
end

return CircularProgress
