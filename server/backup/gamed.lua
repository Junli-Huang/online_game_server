local skynet = require "skynet"

local players = {}

local CMD = {
    init = function (info)
        local gamesocket = skynet.newservice("gamesocket")
        skynet.name(".gamesocket", gamesocket)
        skynet.send(".gamesocket", "lua", "init", info)
    end,

    message = function(id,addr,msg)
        skynet.send(".gamesocket", "lua", "send", id,addr,msg)
    end,

    connect = function(id,addr)
        local player = {id=id,addr=addr}
        players[#players+1] = player
        skynet.error("connect:"..addr)
    end,

    disconnect = function(id,addr)
        for idx,info in ipairs(players) do
            if info.id == id then
               table.remove(players,idx)
               break
            end
        end
        skynet.error("disconnect:"..addr)
    end,
}


skynet.start(function ()
    skynet.dispatch("lua",
        function(session, resource, command, ...)     
            local f = assert(CMD[command])
            skynet.retpack(f(...))
        end
    )
end)