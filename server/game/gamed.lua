local skynet = require "skynet"
local socket = require "skynet.socket"

local players = {}

skynet.register_protocol {
	name = "GAME_SOCKET",
	id = 100,
	pack = skynet.pack,
}

-- 读取客户端数据, 并输出
local function on_connect(info)
    info = info
    socket.start(info.id)
    -- print("on_connect from " .. info.addr .. " " .. info.id)
    players[info.id] = {server = skynet.newservice("player"), addr=info.addr}
    skynet.send(players[info.id].server, "GAME_SOCKET", "on_connect", info)
    while true do 
        -- 读取客户端发过来的数据 
        local data = socket.read(info.id)
        if data then 

            local idx = string.find(data,":")

            while idx do
                
                local size = tonumber(string.sub(data,0,idx-1))
                -- skynet.error(data,size)
                local str = string.sub(data, 0,size)
                -- skynet.error(str)

                skynet.send(players[info.id].server, "GAME_SOCKET", "on_receive", str)
            
                data = string.sub(data, size+1)

                idx = string.find(data,":")
            end


            -- skynet.send(players[info.id].server, "GAME_SOCKET", "on_receive", data)
        else
            skynet.send(players[info.id].server, "GAME_SOCKET", "on_disconnect")
            players[info.id] = nil
            -- print("[close:"..info.addr.."]")
            socket.close(info.id)
            return
        end
    end
end 
    
local CMD = {
    broadcast = function (data)
        for id,server in pairs(players) do
            socket.write(id,data)
        end
    end
}


skynet.start(function() 
    print("==========Socket1 Start=========")
    local id = socket.listen("0.0.0.0", 12224)
    print("Listen socket :", "0.0.0.0", 12224)

    socket.start(id , function(id, addr)
        local info = {id=id,addr=addr}
        on_connect(info)
    end)

    skynet.dispatch(
        "lua",
        function(session, resource, command, ...)     
            local f = assert(CMD[command])
            skynet.retpack(f(...))
        end
    )

end)