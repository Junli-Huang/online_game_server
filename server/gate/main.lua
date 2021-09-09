local skynet = require "skynet"


skynet.start(function ()

    local socket = skynet.newservice("socket")


    skynet.exit()
end)