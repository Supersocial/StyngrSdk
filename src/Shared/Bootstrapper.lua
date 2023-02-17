--[[
    Small bootstrapper script
]]
return function(parent: Instance): ()
	assert(parent and typeof(parent) == "Instance", "Bad parent")

	local scripts = parent:GetChildren()
	local initializationPool = {}

	-- Iterate through client scripts and add them
	-- to init pool if they're valid
	for _, handler in scripts do
		if not handler:IsA("ModuleScript") then continue end
		local module = require(handler)

		-- only add modules with start and / or init methods
		if not module.Init and not module.Start then continue end

		initializationPool[handler.Name] = module
	end

	-- initialize all modules
	for handler, module in initializationPool do
		print(string.format("Initializing %s", handler))

		module:Init()
	end

	-- start all modules
	for handler, module in initializationPool do
		print(string.format("Starting %s", handler))

		module:Start()
	end
end