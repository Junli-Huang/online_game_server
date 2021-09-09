local gateserver = require "snax.gateserver"

local handler = {}

function handler.connect(fd, ipaddr)
	print("fd:"..fd.." ipaddr:".. ipaddr)
end
function handler.message(fd, msg, sz)
	print("fd:"..fd.." msg:".. msg.." sz:".. sz)
end

print("1111")

gateserver.start(handler)
