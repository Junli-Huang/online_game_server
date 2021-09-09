local skynet = require "skynet"


skynet.start(function ()

    local gamed = skynet.newservice("gamed")
    skynet.name(".gamed",gamed)


    skynet.exit()
end)