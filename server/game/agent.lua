local skynet = require "skynet"
local socket = require "skynet.socket"

local pb = require "protobuf"


local socketdriver = require "socketdriver"

local CMD = {}

local client_fd


skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack =  skynet.tostring,
	dispatch = function (fd, _, data)
		assert(fd == client_fd)	-- You can use fd to reply message
		skynet.ignoreret()	-- session is fd, don't call skynet.ret

		local result = pb.decode("Item.Use", data)
		luadump(result)


		local stringbuffer = pb.encode("Item.Buy", 
		{
		  id = 777,
		  num = result.num*10,
		})

		local package = string.pack(">s2", stringbuffer)

		socketdriver.send(client_fd, package)

	end
	}
	
function CMD.start(conf)
	print("[CMD.start] ")
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	print("[CMD.disconnect] ")
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)

		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	pb.register_file("./protocol/descriptor_set")
end)
