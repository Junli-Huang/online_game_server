local skynet = require "skynet"

skynet.register_protocol {
	name = "hjl",
	id = 111,
    unpack = skynet.unpack,
	dispatch = function (fd, from, type, ...)
        skynet.error("--->%d,%d,%s",fd, from, type,...)
	end
}

skynet.start(function ()

end)