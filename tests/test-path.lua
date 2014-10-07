--[[

Copyright 2012 The Luvit Authors. All Rights Reserved.

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

require("helper")

local path = require('path')
local path_base = require('path_base')
local os = require('os')

-- test `path.dirname`
if (os.type() ~= "win32") then
  assert(path.dirname('/usr/bin/vim') == '/usr/bin')
  assert(path.dirname('/usr/bin/') == '/usr')
  assert(path.dirname('/usr/bin') == '/usr')
else
  assert(path.dirname('C:\\Users\\philips\\vim.exe') == 'C:\\Users\\philips')
  assert(path.dirname('C:\\Users\\philips\\') == 'C:\\Users')
  assert(path.dirname('D:\\Users\\philips\\') == 'D:\\Users')
  assert(path.dirname('C:\\') == 'C:\\')
  assert(path.dirname('\\\\server\\share\\Users\\philips\\') == '\\\\server\\share\\Users')
  assert(path.dirname('\\\\server\\share\\') == '\\\\server\\share\\')
end

-- Test out the OS path objects
assert(path_base.posix:dirname('/usr/bin/vim') == '/usr/bin')
assert(path_base.posix:dirname('/usr/bin/') == '/usr')
assert(path_base.posix:dirname('/usr/bin') == '/usr')
assert(path_base.nt:dirname('C:\\Users\\philips\\vim.exe') == 'C:\\Users\\philips')
assert(path_base.nt:dirname('D:\\Users\\philips\\vim.exe') == 'D:\\Users\\philips')
assert(path_base.nt:dirname('\\\\server\\share\\Users\\philips\\vim.exe') == '\\\\server\\share\\Users\\philips')
assert(path_base.nt:dirname('C:\\Users\\philips\\') == 'C:\\Users')
assert(path_base.nt:dirname('D:\\Users\\philips\\') == 'D:\\Users')
assert(path_base.nt:dirname('\\\\server\\share\\Users\\philips\\') == '\\\\server\\share\\Users')
assert(path_base.nt:dirname('\\\\server\\share\\') == '\\\\server\\share\\')

assert(path_base.posix:join('foo', '/bar') == "foo/bar")
assert(path_base.posix:join('foo', 'bar') == "foo/bar")
assert(path_base.posix:join('foo/', 'bar') == "foo/bar")
assert(path_base.posix:join('foo/', '/bar') == "foo/bar")
assert(path_base.posix:join('/foo', '/bar') == "/foo/bar")
assert(path_base.posix:join('/foo', 'bar') == "/foo/bar")
assert(path_base.posix:join('/foo/', 'bar') == "/foo/bar")
assert(path_base.posix:join('/foo/', '/bar') == "/foo/bar")
assert(path_base.posix:join('foo', '/bar/') == "foo/bar/")
assert(path_base.posix:join('foo', 'bar/') == "foo/bar/")
assert(path_base.posix:join('foo/', 'bar/') == "foo/bar/")
assert(path_base.posix:join('foo/', '/bar/') == "foo/bar/")

assert(path.basename('bar.lua') == 'bar.lua')
assert(path.basename('bar.lua', '.lua') == 'bar')
assert(path.basename('bar.lua.js', '.lua') == 'bar.lua.js')
assert(path.basename('.lua', 'lua') == '.')
assert(path.basename('bar', '.lua') == 'bar')

-- test path.basename os specifics
assert(path_base.posix:basename('/foo/bar.lua') == 'bar.lua')
assert(path_base.posix:basename('/foo/bar.lua', '.lua') == 'bar')
assert(path_base.nt:basename('c:\\foo\\bar.lua') == 'bar.lua')
assert(path_base.nt:basename('c:\\foo\\bar.lua', '.lua') == 'bar')
assert(path_base.nt:basename('D:\\foo\\bar.lua') == 'bar.lua')
assert(path_base.nt:basename('D:\\foo\\bar.lua', '.lua') == 'bar')
assert(path_base.nt:basename('\\\\server\\share\\bar.lua') == 'bar.lua')
assert(path_base.nt:basename('\\\\server\\share\\bar.lua', '.lua') == 'bar')

-- test path.isAbsolute
assert(path_base.posix:isAbsolute('/foo/bar.lua'))
assert(not path_base.posix:isAbsolute('foo/bar.lua'))
assert(path_base.nt:isAbsolute('C:\\foo\\bar.lua'))
assert(path_base.nt:isAbsolute('D:\\foo\\bar.lua'))
assert(not path_base.nt:isAbsolute('foo\\bar.lua'))
assert(path_base.nt:isAbsolute('\\\\server\\share\\bar.lua'))
assert(path_base.nt:isAbsolute('\\\\server\\'))

-- test path.getRoot
assert(path_base.posix:getRoot() == '/')
assert(path_base.posix:getRoot('irrelevant') == '/')
assert(path_base.nt:getRoot() == 'c:\\')
assert(path_base.nt:getRoot('C:\\foo\\bar.lua') == 'C:\\')
assert(path_base.nt:getRoot('d:\\foo\\bar.lua') == 'd:\\')
assert(path_base.nt:getRoot('d:') == 'd:\\')
assert(path_base.nt:getRoot('\\\\server\\share\\bar.lua') == '\\\\server\\share\\')
assert(path_base.nt:getRoot('\\\\server\\share') == '\\\\server\\share\\')
assert(path_base.nt:getRoot('\\\\server\\') == '\\\\server\\')
assert(path_base.nt:getRoot('\\\\server') == '\\\\server\\')

-- test path._splitPath
assert(deep_equal({"/", "foo/", "bar.lua"}, {path_base.posix:_splitPath('/foo/bar.lua')}))
assert(deep_equal({"", "foo/", "bar.lua"}, {path_base.posix:_splitPath('foo/bar.lua')}))
assert(deep_equal({"C:\\", "foo\\", "bar.lua"}, {path_base.nt:_splitPath('C:\\foo\\bar.lua')}))
assert(deep_equal({"d:\\", "foo\\", "bar.lua"}, {path_base.nt:_splitPath('d:\\foo\\bar.lua')}))
assert(deep_equal({"", "foo\\", "bar.lua"}, {path_base.nt:_splitPath('foo\\bar.lua')}))
assert(deep_equal({"\\\\server\\share\\", "", "bar.lua"}, {path_base.nt:_splitPath('\\\\server\\share\\bar.lua')}))

-- test path._normalizeArray
local dotArray = {"foo", ".", "bar"}
path._normalizeArray(dotArray)
assert(deep_equal({"foo", "bar"}, dotArray))

local dotdotArray = {"..", "foo", "..", "bar"}
path._normalizeArray(dotdotArray)
assert(deep_equal({"bar"}, dotdotArray))

local dotdotRelativeArray = {"..", "foo", "..", "bar"}
path._normalizeArray(dotdotRelativeArray, true)
assert(deep_equal({"..", "bar"}, dotdotRelativeArray))

-- test path.normalize
-- trailing slash
assert(path_base.posix:normalize("foo/bar") == "foo/bar")
assert(path_base.posix:normalize("foo/bar/") == "foo/bar/")
assert(path_base.posix:normalize("/foo/bar") == "/foo/bar")
assert(path_base.posix:normalize("/foo/bar/") == "/foo/bar/")
assert(path_base.nt:normalize("\\foo\\bar") == "foo\\bar")
assert(path_base.nt:normalize("\\foo\\bar\\") == "foo\\bar\\")
assert(path_base.nt:normalize("C:\\foo\\bar") == "C:\\foo\\bar")
assert(path_base.nt:normalize("C:\\foo\\bar\\") == "C:\\foo\\bar\\")
assert(path_base.nt:normalize("D:\\foo\\bar") == "D:\\foo\\bar")
assert(path_base.nt:normalize("D:\\foo\\bar\\") == "D:\\foo\\bar\\")
assert(path_base.nt:normalize("\\\\server\\share\\bar") == "\\\\server\\share\\bar")
assert(path_base.nt:normalize("\\\\server\\share\\bar\\") == "\\\\server\\share\\bar\\")
assert(path_base.nt:normalize("\\\\a") == "\\\\a\\")
assert(path_base.nt:normalize("\\\\a\\b") == "\\\\a\\b\\")
-- dot and dotdot
assert(path_base.posix:normalize("foo/../bar.lua") == "bar.lua")
assert(path_base.posix:normalize("foo/./bar.lua") == "foo/bar.lua")
assert(path_base.posix:normalize("/foo/../bar.lua") == "/bar.lua")
assert(path_base.posix:normalize("/foo/./bar.lua") == "/foo/bar.lua")
assert(path_base.nt:normalize("foo\\..\\bar.lua") == "bar.lua")
assert(path_base.nt:normalize("foo\\.\\bar.lua") == "foo\\bar.lua")
assert(path_base.nt:normalize("C:\\foo\\..\\bar.lua") == "C:\\bar.lua")
assert(path_base.nt:normalize("C:\\foo\\.\\bar.lua") == "C:\\foo\\bar.lua")
assert(path_base.nt:normalize("D:\\foo\\..\\bar.lua") == "D:\\bar.lua")
assert(path_base.nt:normalize("D:\\foo\\.\\bar.lua") == "D:\\foo\\bar.lua")
assert(path_base.nt:normalize("\\\\server\\share\\foo\\..\\bar.lua") == "\\\\server\\share\\bar.lua")
assert(path_base.nt:normalize("\\\\server\\share\\.\\bar.lua") == "\\\\server\\share\\bar.lua")
assert(path_base.nt:normalize("\\\\server\\share\\..\\bar.lua") == "\\\\server\\share\\bar.lua")
assert(path_base.nt:normalize("\\\\server\\..\\bar.lua") == "\\\\server\\bar.lua")
-- dot and dotdot only (relative, absolute, with/without trailing slashes)
assert(path_base.posix:normalize("./") == ".")
assert(path_base.posix:normalize("../") == "../")
assert(path_base.posix:normalize("/.") == "/")
assert(path_base.posix:normalize("/./") == "/")
assert(path_base.posix:normalize("/..") == "/")
assert(path_base.posix:normalize("/../") == "/")
assert(path_base.nt:normalize(".\\") == ".")
assert(path_base.nt:normalize("..\\") == "..\\")
assert(path_base.nt:normalize("C:\\.") == "C:\\")
assert(path_base.nt:normalize("C:\\.\\") == "C:\\")
assert(path_base.nt:normalize("C:\\..") == "C:\\")
assert(path_base.nt:normalize("C:\\..\\") == "C:\\")
assert(path_base.nt:normalize("D:\\.") == "D:\\")
assert(path_base.nt:normalize("D:\\.\\") == "D:\\")
assert(path_base.nt:normalize("D:\\..") == "D:\\")
assert(path_base.nt:normalize("D:\\..\\") == "D:\\")
assert(path_base.nt:normalize("\\\\server\\.") == "\\\\server\\")
assert(path_base.nt:normalize("\\\\server\\.\\") == "\\\\server\\")
assert(path_base.nt:normalize("\\\\server\\..") == "\\\\server\\")
assert(path_base.nt:normalize("\\\\server\\..\\") == "\\\\server\\")

-- test path.join
assert(path_base.posix:join('.', 'foo/bar', '..', '/foo/bar.lua') == 'foo/foo/bar.lua')
assert(path_base.posix:join('/.', 'foo/bar', '..', '/foo/bar.lua') == '/foo/foo/bar.lua')
assert(path_base.posix:join('/foo', '../../../bar') == '/bar')
assert(path_base.posix:join('foo', '../../../bar') == '../../bar')
assert(path_base.posix:join('foo/', '../../../bar') == '../../bar')
assert(path_base.posix:join('foo/bar', '../../../bar') == '../bar')
assert(path_base.posix:join('foo/bar', './bar') == 'foo/bar/bar')
assert(path_base.posix:join('foo/bar/', './bar') == 'foo/bar/bar')
assert(path_base.posix:join('foo/bar/', '.', 'bar') == 'foo/bar/bar')
assert(path_base.posix:join('.', './') == '.')
assert(path_base.posix:join('.', '.', '.') == '.')
assert(path_base.posix:join('.', './', '.') == '.')
assert(path_base.posix:join('.', '/./', '.') == '.')
assert(path_base.posix:join('.', '/////./', '.') == '.')
assert(path_base.posix:join('.') == '.')
assert(path_base.posix:join('', '.') == '.')
assert(path_base.posix:join('', 'foo') == 'foo')
assert(path_base.posix:join('foo', '/bar') == 'foo/bar')
assert(path_base.posix:join('', '/foo') == '/foo')
assert(path_base.posix:join('', '', '/foo') == '/foo')
assert(path_base.posix:join('', '', 'foo') == 'foo')
assert(path_base.posix:join('foo', '') == 'foo')
assert(path_base.posix:join('foo/', '') == 'foo/')
assert(path_base.posix:join('foo', '', '/bar') == 'foo/bar')
assert(path_base.posix:join('./', '..', '/foo') == '../foo')
assert(path_base.posix:join('./', '..', '..', '/foo') == '../../foo')
assert(path_base.posix:join('.', '..', '..', '/foo') == '../../foo')
assert(path_base.posix:join('', '..', '..', '/foo') == '../../foo')
assert(path_base.posix:join('/') == '/')
assert(path_base.posix:join('/', '.') == '/')
assert(path_base.posix:join('/', '..') == '/')
assert(path_base.posix:join('/', '..', '..') == '/')
assert(path_base.posix:join('') == '.')
assert(path_base.posix:join('', '') == '.')
assert(path_base.posix:join('/', 'foo') == '/foo')
assert(path_base.posix:join('/', '/foo') == '/foo')
assert(path_base.posix:join('/', '//foo') == '/foo')
assert(path_base.posix:join('/', '', '/foo') == '/foo')
assert(path_base.posix:join('', '/', 'foo') == '/foo')
assert(path_base.posix:join('', '/', '/foo') == '/foo')
-- Interpretted as UNC paths
assert(path_base.nt:join('\\\\foo\\bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo', 'bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo\\', 'bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo', '\\bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo', '', 'bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo\\', '', 'bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo\\', '', '\\bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('', '\\\\foo', 'bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('', '\\\\foo\\', 'bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('', '\\\\foo\\', '\\bar') == '\\\\foo\\bar\\')
assert(path_base.nt:join('\\\\foo') == '\\\\foo\\')
assert(path_base.nt:join('\\\\foo\\') == '\\\\foo\\')
assert(path_base.nt:join('\\\\foo', '\\') == '\\\\foo\\')
assert(path_base.nt:join('\\\\foo', '', '\\') == '\\\\foo\\')
-- Not interpretted as UNC paths
assert(path_base.nt:join('\\', 'foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('\\', '\\foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('', '\\', '\\foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('\\\\', 'foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('\\\\', '\\foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('\\\\', '\\', '\\foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('\\\\\\foo\\bar') == 'foo\\bar')
assert(path_base.nt:join('\\\\\\\\foo', 'bar') == 'foo\\bar')
assert(path_base.nt:join('\\\\\\\\foo\\bar') == 'foo\\bar')

-- test path.resolve
assert(path_base.posix:resolve('/var/lib', '../', 'file/') == '/var/file/')
assert(path_base.posix:resolve('/var/lib', '/../', 'file/') == '/file/')
assert(path_base.posix:resolve('a/b/c/', '../../..') == process.cwd())
assert(path_base.posix:resolve('.') == process.cwd())
assert(path_base.posix:resolve('/some/dir', '.', '/absolute/') == '/absolute/')
assert(path_base.nt:resolve('c:\\blah\\blah', 'd:\\games', 'c:\\..\\a') == 'c:\\a')
assert(path_base.nt:resolve('c:\\ignore', 'd:\\a\\b\\c\\d', '\\e.exe') == 'd:\\a\\b\\c\\d\\e.exe')
assert(path_base.nt:resolve('c:\\ignore', 'c:\\some\\file') == 'c:\\some\\file')
assert(path_base.nt:resolve('d:\\ignore', 'd:\\some\\dir\\\\') == 'd:\\some\\dir\\')
assert(path_base.nt:resolve('.') == process.cwd())
assert(path_base.nt:resolve('\\\\server\\share', '..', 'relative\\') == '\\\\server\\share\\relative\\')
assert(path_base.nt:resolve('c:\\', '\\\\') == 'c:\\')
assert(path_base.nt:resolve('c:\\', '\\\\dir') == '\\\\dir\\')
assert(path_base.nt:resolve('c:\\', '\\\\server\\share') == '\\\\server\\share\\')
assert(path_base.nt:resolve('c:\\', '\\\\server\\\\share') == '\\\\server\\share\\')
assert(path_base.nt:resolve('c:\\', '\\\\\\some\\\\dir') == 'c:\\some\\dir')
