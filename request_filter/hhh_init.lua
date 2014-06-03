#!/usr/bin/env lua

REQUEST_COUNTER = ngx.shared.REQUEST_COUNTER
CONFIG = ngx.shared.CONFIG

CONFIG:set('FLUSH_INTERVAL', 300)  -- giay


statsd = require "statsd";
Statsd = statsd.new("127.0.0.1", 8125, "STATSD", 0)



