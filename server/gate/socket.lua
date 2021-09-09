local skynet = require "skynet"
local socket = require "skynet.socket"

local standins = {}

skynet.register_protocol {
	name = "GAME_SOCKET",
	id = 100,
	pack = skynet.pack,
}

-- 读取客户端数据, 并输出
local function on_connect(info)
    -- 每当 accept 函数获得一个新的 socket id 后，并不会立即收到这个 socket 上的数据。这是因为，我们有时会希望把这个 socket 的操作>权转让给别的服务去处理。
    -- 任何一个服务只有在调用 socket.start(id) 之后，才可以收到这个 socket 上的数据。

    socket.start(info.id)
    -- print("on_connect from " .. info.addr .. " " .. info.id)
    standins[info.addr] = skynet.newservice("standin")
    skynet.send(standins[info.addr], "GAME_SOCKET", "on_connect", info)
    while true do 
        -- 读取客户端发过来的数据 
        local data = socket.read(info.id)
        if data then 
            -- 直接打印接收到的数据
            -- skynet.error("msg: "..data.." [from:"..info.addr.."]")


            local idx = string.find(data,":")

            while idx do
                
                local size = tonumber(string.sub(data,0,idx-1))
                -- skynet.error(data,size)
                local str = string.sub(data, 0,size)
                -- skynet.error(str)

                skynet.send(standins[info.addr], "GAME_SOCKET", "on_receive", str)
            
                data = string.sub(data, size+1)

                idx = string.find(data,":")
            end


            -- skynet.send(standins[info.addr], "GAME_SOCKET", "on_receive", data)
        else
            skynet.send(standins[info.addr], "GAME_SOCKET", "on_disconnect")
            standins[info.addr] = nil
            -- print("[close:"..info.addr.."]")
            socket.close(info.id)
            return
        end
    end
end 
    
skynet.start(function() 
    print("==========Socket1 Start=========")
    -- 监听一个端口，返回一个 id ，供 start 使用。
    local id = socket.listen("0.0.0.0", 12224)
    print("Listen socket :", "0.0.0.0", 12224)

    socket.start(id , function(id, addr)
            local info = {id=id,addr=addr}
            -- 接收到客户端连接或发送消息()
            

            -- 处理接收到的消息
            on_connect(info)

        end)
    --可以为自己注册一个别名。（别名必须在 32 个字符以内）
    -- skynet.register "SOCKET"
end)