-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet
----------------------------------------------------------------------
-- @author Daniel Barney <daniel@pagodabox.com>
-- @copyright 2015, Pagoda Box, Inc.
-- @doc
--
-- @end
-- Created :   15 May 2015 by Daniel Barney <daniel@pagodabox.com>
----------------------------------------------------------------------

local Cauterize = require('cauterize')
local Pid = require('cauterize/lib/pid')
local Process = Cauterize.Process
local Reactor = Cauterize.Reactor
require('tap')(function (test)
	
	test('create a process',function()
		local ran = false
		local pid = Process:new(function()
			ran = true
		end)
		assert(Pid.lookup(pid),'pid does not exist')
		Reactor:_step(Pid.lookup(pid))
		assert(ran,'the process did not run')
	end)

end)