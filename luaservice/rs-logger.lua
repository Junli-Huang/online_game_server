local skynet = require "skynet"
require "skynet.manager"

local queue = require "skynet.queue"
local cs = queue()

local nodename = skynet.getenv("nodename")


local BLACK  = 30
local RED    = 31
local GREEN  = 32
local YELLOW = 33
local BLUE   = 34
local PURPLE = 35
local CYAN   = 36
local GRAY   = 37
local COLOR_FORMAT = "\x1b[%dm"
local COLOR_DEFAULT = "\x1b[m"
local COLOR_BY_LOG_TYPE = {
	DEBUG = COLOR_DEFAULT,
	INFO = string.format(COLOR_FORMAT, GREEN),
	WARNING = string.format(COLOR_FORMAT, YELLOW),
	ERROR = string.format(COLOR_FORMAT, RED),
	FATAL = string.format(COLOR_FORMAT, PURPLE),
	SKY = string.format(COLOR_FORMAT, BLUE),
}

local LOG_PATH = LOG_PATH

local MB = 1024 * 1024
local FILE_LIMIT = 32 * MB
local FILE_ROLL_TIME = 24 * 60 * 60 * 60


local _logerr = nil
local _logfile = nil
local _logstarttime = nil
local _logname = ""
local _logsize = 0
local _logidx = 0

local _log_stat = {cnt = 0}

local CMD = {}


local function str_time(ot)
	local t = os.date("*t", ot)
	return string.format("%04d-%02d-%02d %02d:%02d:%02d.%02d", 
        t.year, t.month, t.day, t.hour, t.min, t.sec, math.floor(skynet.time()*100%100))
end


local function str_logfilename(ot)
	local t = os.date("*t", ot)
	return string.format("./%s/%s_%04d%02d%02d_%02d%02d%02d_%02d.log", 
		LOG_PATH, nodename, t.year, t.month, t.day, t.hour, t.min, t.sec, _logidx)
end


local function record(typ, log)
	if not _log_stat[typ] then
		_log_stat[typ] = {cnt = 0}
	end
	_log_stat[typ].cnt = _log_stat[typ].cnt + 1
	_log_stat[typ].last = log
	_log_stat.cnt = _log_stat.cnt + 1
end


local function logging(source, typ, log)
	cs(function()
		local ot = os.time()
		local log = string.format("[%s] [%s] [%s:%x] %s", str_time(ot), typ, nodename, source, log)
		print(string.format("%s%s%s", COLOR_BY_LOG_TYPE[typ], log, COLOR_DEFAULT))
		record(typ, log)

		if not _logfile then
			_logname = str_logfilename(ot)
			_logfile, _logerr = io.open(_logname, "a+")
			if not _logfile then
				print("logger error:", tostring(_logerr))
				-- skynet.abort()
				return
			end
			_logstarttime = ot
			_log_stat.logname = _logname
		end

		_logfile:write(log)
		_logfile:write('\n')
		_logfile:flush()

		_logsize = _logsize + string.len(log) + 1
		if _logsize > FILE_LIMIT or os.difftime(ot, _logstarttime) > FILE_ROLL_TIME then
			_logfile:close()
			_logfile = nil
			_logsize = 0
			_logidx = _logidx + 1
		end
	end)
end


function CMD.logging(source, typ, log)
	logging(source, typ, log)
end


function CMD.stat()
	_log_stat.logsize = _logsize
	skynet.retpack(_log_stat)
end


skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
        logging(address, "SKY", msg)
	end
}


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		f(source, ...)
	end)

	skynet.register(".logger")
	logging(skynet.self(), "SKY", "rs-logger ready.")
end)
