local skynet = require "skynet"

skynet.start(function ()


	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 12000,
		nodelay = true,
	})

	skynet.exit()

    -- local gamed = skynet.newservice("gamed")
    -- print(tostring(skynet.name))
    -- skynet.name(".gamed",gamed)
    -- skynet.send(".gamed","lua","init",{
    --     ip = "0.0.0.0", 
    --     port = 12000,
    -- })

    skynet.exit()
end)