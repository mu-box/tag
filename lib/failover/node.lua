-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet

local Cauterize = require('cauterize')
local Name = require('cauterize/lib/name')
local Group = require('cauterize/lib/group')
local log = require('logger')
local util = require('../util')
local Node = Cauterize.Fsm:extend()

function Node:_init(config)
  self.state = 'down'

  -- dynamic config options
  self.needed_quorum = util.config_watch(self:current(), 'needed_quorum',
    'quorum_update')
  self.node_wait_for_response_intreval = util.config_watch(self:current(),
    'node_wait_for_response_interval', 'udpate_config')

  self.reports = {}
  self.timers = {}
  self.name = config.name
  Name.register(self:current(),self.name)
  Group.join(self:current(),'nodes')
  self:send({'group','systems'},'$cast',{'down',self.name})
end

-- set up some states
Node.down = {}
Node.up = {}

-- we got an update to the config value, lets set it
function Node:update_config(key,value)
  self[key] = value
end

function Node:quorum_update(key,value)
  assert(key == 'needed_quorum',
    'wrong key was passed to update quorum')
  self[key] = value

  -- we we need to recheck our node state
  self:change_state_if_quorum_satisfied()
end


-- we only want to check if we need to change states if up is called
-- in the down state or down in the up state.
function Node.down:up(who)
  self:set_remote_report(who,true)
  self:change_state_if_quorum_satisfied()
end

function Node.up:down(who)
  self:set_remote_report(who,false)
  self:change_state_if_quorum_satisfied()
end

-- up in up and down in down can't change the state
function Node.up:up(who)
  self:set_remote_report(who,true)
end

function Node.down:down(who)
  self:set_remote_report(who,false)
end

function Node.up:suspicious(who)
  self.suspicious_reporter = who
  Node.up.down(self,who)
end

function Node:set_remote_report(who,node_is_up)
  if node_is_up and
      self.suspicious_reporter and who ==
      self.suspicious_reporter then
    self.suspicious_reporter = nil
  end
  -- cancel a timer if one was created
  if self.timers[who] then
    self:cancel_timer(self.timers[who])
    self.timers[who] = nil
  end
  self.reports[who] = node_is_up
end

-- we are going to be waiting for this node to respond, start a timer
-- so that if it doesn't respond in time we will automatically mark
-- this node as down
function Node.up:start_timer(who)
  self.timers[who] = self:send_after('$self',
    self.node_wait_for_response_intreval, '$cast', {'suspicious', who})
end

function Node:get_state()
  if self.suspicious_reporter then
    return "suspicious"
  else
    return self.state
   end
end

function Node:change_state_if_quorum_satisfied()
  local up_quorum_count = 0
  for _,node_is_up in pairs(self.reports) do
    if node_is_up then
      up_quorum_count = up_quorum_count + 1
    end
  end
  if up_quorum_count >= self.needed_quorum then
    self:change_to_new_state_and_notify('up')
  else
    -- this is also a quorum, but for down.
    self:change_to_new_state_and_notify('down')
  end
end

-- only change state if the new_state is different from the current
-- state
function Node:change_to_new_state_and_notify(new_state)
  if self.state ~= new_state then
    self.state = new_state
    log.warning('node changed state',self.name,new_state)

    -- notify all systems that this node changed state
    self:send({'group','systems'},'$cast',{new_state,self.name})

    -- this will cause all reports generated by this node to be
    -- invalidated, which is what we want if we can't communicate with
    -- this node
    if new_state == 'down' then
      self:send({'group','nodes'},'$cast',{new_state,self.name})
   end
  end
end

return Node
