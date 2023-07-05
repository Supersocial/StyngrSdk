local DateTimeOffset = {}

function DateTimeOffset.GetCurrentUtcOffset()
	local utcOffsetString = ""
	
	-- Get the current UTC time
	local utcTime = os.time(os.date("!*t"))

	-- Get the local time
	local localTime = os.time(os.date("*t"))

	-- Calculate the timezone offset in seconds
	local timezoneOffset = os.difftime(localTime, utcTime)

	-- Convert the offset to hours
	local timezoneOffsetInHours = timezoneOffset / 3600
	
	if timezoneOffsetInHours > 0 then
		utcOffsetString = string.format("UTC+%0.2i:00", timezoneOffsetInHours)
	elseif timezoneOffsetInHours < 0 then
		utcOffsetString = string.format("UTC%0.2i:00", timezoneOffsetInHours)
	else
		utcOffsetString = string.format("UTC+00:00", timezoneOffsetInHours)
	end
	
	return utcOffsetString
end

return DateTimeOffset
