--[[

Copyright 2014-2015 The Luvit Authors. All Rights Reserved.

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

--[[lit-meta
  name = "luvit/repl"
  version = "2.0.2"
  dependencies = {
    "luvit/utils@2.0.0",
    "luvit/readline@2.0.0",
  }
  license = "Apache 2"
  homepage = "https://github.com/luvit/luvit/blob/master/deps/repl.lua"
  description = "Advanced auto-completing repl for luvit lua."
  tags = {"luvit", "tty", "repl"}
]]

local utils = require('utils')
local Editor = require('readline').Editor
local History = require('readline').History


return function (stdin, stdout, greeting)

  setmetatable(_G, {
    __index = function (_, key)
      if key == "thread" then return coroutine.running() end
    end
  })

  if greeting then stdout:write(greeting .. '\n') end

  local c = utils.color

  local function gatherResults(success, ...)
    local n = select('#', ...)
    return success, { n = n, ... }
  end

  local function printResults(results)
    for i = 1, results.n do
      results[i] = utils.dump(results[i])
    end
    stdout:write(table.concat(results, '\t') .. '\n')
  end

  local buffer = ''

  local function evaluateLine(line)
    if line == "<3" or line == "♥" then
      stdout:write("I " .. c("err") .. "♥" .. c() .. " you too!\n")
      return '>'
    end
    local chunk  = buffer .. line
    local f, err = loadstring('return ' .. chunk, 'REPL') -- first we prefix return

    if not f then
      f, err = loadstring(chunk, 'REPL') -- try again without return
    end


    if f then
      buffer = ''
      local success, results = gatherResults(xpcall(f, debug.traceback))

      if success then
        -- successful call
        if results.n > 0 then
          printResults(results)
        end
      elseif type(results[1]) == 'string' then
        -- error
        stdout:write(results[1] .. '\n')
      else
        -- error calls with non-string message objects will pass through debug.traceback without a stacktrace added
        stdout:write('error with unexpected error message type (' .. type(results[1]) .. '), no stacktrace available\n')
      end
    else

      if err:match "'<eof>'$" then
        -- Lua expects some more input; stow it away for next time
        buffer = chunk .. '\n'
        return '>> '
      else
        stdout:write(err .. '\n')
        buffer = ''
      end
    end

    return '> '
  end

  local function completionCallback(line)
    local base, sep, rest = string.match(line, "^(.*)([.:])(.*)")
    if not base then
      rest = line
    end
    local prefix = string.match(rest, "^[%a_][%a%d_]*")
    if prefix and prefix ~= rest then return end
    local scope
    if base then
      local f = loadstring("return " .. base)
      scope = f()
    else
      base = ''
      sep = ''
      scope = _G
    end
    local matches = {}
    local prop = sep ~= ':'
    while type(scope) == "table" do
      for key, value in pairs(scope) do
        if (prop or (type(value) == "function")) and
           ((not prefix) or (string.match(key, "^" .. prefix))) then
          matches[key] = true
        end
      end
      scope = getmetatable(scope)
      scope = scope and scope.__index
    end
    local items = {}
    for key in pairs(matches) do
      items[#items + 1] = key
    end
    table.sort(items)
    if #items == 1 then
      return base .. sep .. items[1]
    elseif #items > 1 then
      return items
    end
  end

  local function start(historyLines, onSaveHistoryLines)
    local prompt = "> "
    local history = History.new()
    if historyLines then
      history:load(historyLines)
    end
    local editor = Editor.new({
      stdin = stdin,
      stdout = stdout,
      completionCallback = completionCallback,
      history = history
    })

    local function onLine(err, line)
      assert(not err, err)
      coroutine.wrap(function ()
        if line then
          prompt = evaluateLine(line)
          editor:readLine(prompt, onLine)
          -- TODO: break out of >> with control+C
        elseif onSaveHistoryLines then
          onSaveHistoryLines(history:dump())
        end
      end)()
    end

    editor:readLine(prompt, onLine)

  end

  return {
    start = start,
    evaluateLine = evaluateLine,
  }
end
