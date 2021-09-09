local skynet = require "skynet"
local socket = require "skynet.socket"

local socket_info = ...
local GAME_SOCKET = {
	
	on_connect = function (info)
		socket_info = info
		print("connect from " .. socket_info.addr .. " " .. socket_info.id)

	end,
	on_receive = function (data)
		print("receive: "..data.." [from:"..socket_info.addr.."]")
		-- socket.start(socket_info.id)

		socket.write(socket_info.id, data)
	end,
	on_disconnect = function ()
		print("[disconnect:"..socket_info.addr.."]")

		skynet.exit()
	end
}

skynet.register_protocol {
	name = "GAME_SOCKET",
	id = 100,
	pack = skynet.pack,
	unpack = skynet.unpack,
	dispatch = function (session, from, type, data)
		local f = assert(GAME_SOCKET[type])
		skynet.retpack(f(data))
	end
}


skynet.start(function ()
	
end)