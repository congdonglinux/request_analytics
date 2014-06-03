local statsd = {}

local Methods = {}
local mt      = {__index = Methods}

local function get_dict(self)
  local dict = ngx.shared[self.dict]
  if not dict then
    error('The dictionary ' .. self.dict .. ' was not found. Please create it by adding `lua_shared_dict ' .. self.dict .. ' 20k;` to the ngx config file')
  end
  return dict
end

function Methods:time(bucket, time)
  self:register(bucket, time, "ms")
end

function Methods:count(bucket, n)
  self:register(bucket, n, 'c')
end

function Methods:incr(bucket, n)
  self:count(bucket, 1)
end

function Methods:gauge(bucket, n)
    self:register(bucket, n, 'g')
end

function Methods:set(bucket, n)
    self:register(bucket, n, 's')
end

function Methods:sored_set(bucket, n)
    self:register(bucket, n, 'z')
end

function Methods:register(bucket, amount, suffix)
  local dict = get_dict(self)

  dict:add('last_id', 0)
  local last_id = assert(dict:incr('last_id', 1))

  --- assert(dict:set(last_id, bucket .. ":" .. tostring(amount) .. "|" .. suffix .. "\n"))
  assert(dict:set(last_id, bucket .. ":" .. tostring(amount)))
end

function Methods:flush()
  local dict = get_dict(self)

  local last_id         = tonumber(dict:get('last_id'), 10) or 0
  local last_flushed_id = tonumber(dict:get('last_flushed_id'), 10) or 0

  if last_id - last_flushed_id > self.buffer_size then
    assert(dict:set('last_flushed_id', last_id))
    local buffer, len = {}, 0
    for i=last_flushed_id + 1, last_id do
      len = len + 1
      buffer[len] = assert(dict:get(i))
      dict:delete(i)
    end

    local udp = ngx.socket.udp()
    udp:setpeername(self.host, self.port)
    udp:send(buffer)
    udp:close()
  end
end

statsd.new = function(host, port, dict, buffer_size)
  return setmetatable({
    host        = host or '127.0.0.1',
    port        = port or 8125,
    dict        = dict or 'statsd',
    buffer_size = buffer_size or 50
  }, mt)
end

return statsd
