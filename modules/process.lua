--[[

Copyright 2014 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]

exports.name = "luvit/process"
exports.version = "0.1.0"

local env = require('env')
local hooks = require('hooks')
local os = require('os')
local timer = require('timer')
local utils = require('utils')
local uv = require('uv')
local Emitter = require('core').Emitter

local function nextTick(...)
  timer.setImmediate(...)
end

local function cwd()
  return uv.cwd()
end

local lenv = {}
function lenv.get(key)
  return lenv[key]
end
setmetatable(lenv, {
  __pairs = function(table)
    local keys = env.keys()
    local index = 0
    return function(...)
      index = index + 1
      local name = keys[index]
      if name then
        return name, table[name]
      end
    end
  end,
  __index = function(table, key)
    return env.get(key)
  end,
  __newindex = function(table, key, value)
    if value then
      env.set(key, value, 1)
    else
      env.unset(key)
    end
  end
})

local function kill(pid, signal)
  uv.kill(pid, signal or 'sigterm')
end

local signalWraps = {}

local function on(self, _type, listener)
  if not signalWraps[_type] then
    local signal = uv.new_signal()
    signalWraps[_type] = signal
    uv.unref(signal)
    uv.signal_start(signal, _type, function() self:emit(_type) end)
  end
  Emitter.on(self, _type, listener)
end

local function removeListener(self, _type, listener)
  local signal = signalWraps[_type]
  if not signal then return end
  signal:stop()
  uv.close(signal)
  signalWraps[_type] = nil
  Emitter.removeListener(self, _type, listener)
end

local function exit(self, code)
  code = code or 0
  self:emit('exit', code)
  os.exit(code)
end

local function globalProcess()
  local process = Emitter:new()
  process.argv = args
  process.exitCode = 0
  process.nextTick = nextTick
  process.env = lenv
  process.cwd = cwd
  process.kill = kill
  process.pid = uv.getpid()
  process.on = on
  process.exit = exit
  process.removeListener = removeListener
  hooks:on('process.exit', utils.bind(process.emit, process, 'exit'))
  return process
end
exports.globalProcess = globalProcess