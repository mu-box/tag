-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet

local Cauterize = require('cauterize')
local log = require('logger')

local Basic = require('./basic/basic')
local Replication = require('./replicated/replicated')
local Sync = require('./replicated/sync')
local ConfigLoader = require('./config_loader')

local Store = Cauterize.Supervisor:extend()

function Store:_manage()
  if Cauterize.Supervisor.call('config','get','replicated_db') then
    log.info('enabling replicated mode')
    self:manage(Replication)
        :manage(Sync,'supervisor')
  else
    log.info('enabling single node')
    self:manage(Basic)
  end
  self:manage(ConfigLoader)
end

return Store
