---@diagnostic disable: lowercase-global
skynetroot = "../skynet/"

thread = 4

logger = "rs-logger"
logservice = "snlua"
logpath = "."

harbor = 0
start = "main"


preload = "./lualib/preload.lua"

bootstrap = "snlua bootstrap"
luaservice = skynetroot .. "service/?.lua;"  
			.. "./luaservice/?.lua;"
			.. "./server/game/?.lua;"
			
lualoader = skynetroot .. "lualib/loader.lua"
cpath = skynetroot .. "cservice/?.so"

-- 将添加到 package.path 中的路径，供 require 调用。
lua_path = skynetroot .. "lualib/?.lua;"
			.. skynetroot .. "lualib/compat10/?.lua;"
			.."./lualib/?.lua;"
			.. "./server/game/?.lua;"

lua_cpath = skynetroot .. "luaclib/?.so;" .. "./luaclib/?.so"