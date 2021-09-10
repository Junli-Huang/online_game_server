local skynet = require "skynet"

skynet.start(function ()

    local gamed = skynet.newservice("gamed")
    print(tostring(skynet.name))
    skynet.name(".gamed",gamed)
    skynet.send(".gamed","lua","init",{
        ip = "0.0.0.0", 
        port = 12224,
    })

    skynet.exit()
end)