local ISODurations = {}

--[[
	This is not a fully fledged seconds to ISO Durations converter, it can only do hours -> minutes -> seconds
]]
function ISODurations.TranslateSecondsToDuration(seconds: number)
	assert(seconds < 86400 and seconds > 0, "Seconds out of bounds!")

	local duration = "PT"

	local timeLeft = seconds

	local hours = math.floor(timeLeft / 3600)

	timeLeft -= (hours * 3600)

	local minutes = math.floor(timeLeft / 60)

	timeLeft -= (minutes * 60)

	if hours > 0 then
		duration = duration .. hours .. "H"
	end

	if minutes > 0 then
		duration = duration .. minutes .. "M"
	end

	if timeLeft > 0 then
		duration = duration .. timeLeft .. "S"
	end

	return duration
end

return ISODurations
