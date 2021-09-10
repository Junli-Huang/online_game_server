local skynet = require "skynet"
local socket = require "skynet.socket"

local connections = {}

local function on_read_data(data, connection)
    local idx = string.find(data,":")
    print("> "..data)
    while idx do       
        local size = tonumber(string.sub(data,0,idx-1))
        local str = string.sub(data, 0,size)
        --
        local value = string.find(str,":")
        local msg = string.sub(str, value+1)
        skynet.send(".gamed", "lua", "message", connection.id, connection.addr, msg)
        --
        data = string.sub(data, size+1)
        idx = string.find(data,":")
    end
end

-- 读取客户端数据, 并输出
local function on_connected(id,addr)

    socket.start(id)
    local connection = {id=id, addr=addr}
    connections[#connections+1] = connection
    print("in size:"..#connections)

    skynet.send(".gamed", "lua", "connect", connection.id, connection.addr)

    while true do 
        local data = socket.read(id)
        if data then 

            on_read_data(data, connection)
            
        else
            skynet.send(".gamed", "lua", "disconnect", connection.id, connection.addr)
            for idx,info in ipairs(connections) do
                if info.id == connection.id then
                   table.remove(connections,idx)
                   break
                end
            end
            print("left size:"..#connections)
            socket.close(id)
            return
        end
    end
end 
    
local CMD = {
    -- broadcast = function (data)
    --     for id,server in pairs(socket_fd) do
    --         socket.write(id,data)
    --     end
    -- end

    init = function (info)
        skynet.error("==========Socket Start=========")
        local id = socket.listen(info.ip, info.port)
        skynet.error("Listen socket :", info.ip, info.port)

        socket.start(id , on_connected)
    end,

    send = function (id,addr,msg)

        local length = #msg
        length = length + #tostring(length) + 1
        local data = length..":"..msg
        socket.write(id, data)
    end
}


skynet.start(function() 
    skynet.dispatch(
        "lua",
        function(session, resource, command, ...)     
            local f = assert(CMD[command])
            skynet.retpack(f(...))
        end
    )

end)