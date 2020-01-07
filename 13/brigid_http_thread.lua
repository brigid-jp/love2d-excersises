-- Copyright (c) 2020 <dev@brigid.jp>
-- This software is released under the MIT License.
-- https://opensource.org/licenses/mit-license.php

local love = {
  thread = require "love.thread";
}
local brigid
pcall(function () brigid = require "brigid" end)

local http_request

if brigid then
  function http_request(request)
  end
else
  local socket = {
    http = require "socket.http";
  }

  function http_request(request)
  end
end

local result, message = pcall(function (request)

  -- write file
  -- write data




end, ...)
