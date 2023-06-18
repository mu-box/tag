-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet
local log = require('logger')
local os = require('os')

function main()
  if args[1] == '-server' then
    log.add_logger('info','console',function(...) p(os.date("%x %X"),...) end)
    log.info("starting server")
    table.remove(args,1)
    require('./lib/server')
    -- not reached
  else
    log.add_logger('debug','console',function(...) p(...) end)
    log.debug("entering cli mode")
    require('./lib/cli')
  end
end
main()
