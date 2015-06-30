-- -*- mode: lua; tab-width: 2; indent-tabs-mode: 1; st-rulers: [70] -*-
-- vim: ts=4 sw=4 ft=lua noet
----------------------------------------------------------------------
-- @author Daniel Barney <daniel@pagodabox.com>
-- @copyright 2015, Pagoda Box, Inc.
-- @doc
--
-- @end
-- Created :   26 June 2015 by Daniel Barney <daniel@pagodabox.com>
----------------------------------------------------------------------
local http = require('coro-http')
local uv = require('uv')

function exports.cmd(global, config, bucket, key, value)
  assert(bucket,'need a bucket to enter data')
  assert(key,'need a key to enter data')
  assert(value,'need data to enter')
  local url = table.concat(
    {'http://'
    ,global.host
    ,':'
    ,global.port
    ,'/store/'
    ,bucket
    ,'/'
    ,key})

  coroutine.wrap(function()
    local headers = {}
    if value == '--' then
      p('streaming file')
      local channel = require('coro-channel').wrapStream
      value = channel(uv.new_tty(0, true))
      headers = 
        {{'transfer-encoding','chunked'}}
    end
    local res, data = http.request('POST',url,headers,value)
    if res.code == 200 then
      p(data)
    else
      p('unknown respose', res, data)
    end
  end)()
end

exports.opts = {}