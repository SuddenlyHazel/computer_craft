local luaunit = require('luaunit')
local channel = require("channel")

function TestUnboundedChannel()
  local channel = MpscChannel.new()

  local resultTable = {}

  local hdl = coroutine.create(function()
    while true do
      local msg = channel:receive()
      table.insert(resultTable, msg)
    end
  end)

  coroutine.resume(hdl)

  local result = channel:send("hello world")
  luaunit.assertEquals(result, "ok")
  luaunit.assertEquals(resultTable, { { value = "hello world" } })

  local result = channel:send("hello world 1")
  luaunit.assertEquals(result, "ok")
  luaunit.assertEquals(resultTable, {
    { value = "hello world" },
    { value = "hello world 1" }
  })
end

function TestBoundedChannel()
  local channel = MpscChannel.new(1)

  local resultTable = {}

  local rcv = coroutine.create(function()
    while true do
      local msg = channel:receive()
      table.insert(resultTable, msg)
      break -- take only one message
    end
  end)

  coroutine.resume(rcv)

  local snd = coroutine.create(function()
    local count = 0
    while true do
      local msg = channel:send(count)
      count = count + 1
    end
  end)

  coroutine.resume(snd)

  luaunit.assertEquals(resultTable, { { value = 0 } })
  luaunit.assertEquals(coroutine.status(snd), "suspended")
end

function TestChannelClose()
  local channel = MpscChannel.new()

  local resultTable = {}

  local hdl = coroutine.create(function()
    while true do
      local msg = channel:receive()
      if msg == "closed" then
        break
      end
      table.insert(resultTable, msg)
    end
  end)

  coroutine.resume(hdl)

  local result = channel:send("hello world")
  luaunit.assertEquals(result, "ok")
  luaunit.assertEquals(resultTable, { { value = "hello world" } })

  local result = channel:close()

  luaunit.assertEquals(channel:send("nothing"), "closed")
  luaunit.assertEquals(coroutine.status(hdl), "dead")
end

function TestConsumerFailed()
  local channel = MpscChannel.new()

  local hdl = coroutine.create(function()
    -- terminate coroutine immediately after starting
  end)

  coroutine.resume(hdl)

  local result = channel:send("hello world", 1)
  luaunit.assertEquals(result, "timeout")
end

os.exit(luaunit.LuaUnit.run())
