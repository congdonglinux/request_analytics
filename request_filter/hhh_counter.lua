#!/usr/bin/env lua


local host = ngx.var.host
local content_type = ngx.header.content_type
local http_x_requested_with = ngx.var.http_x_requested_with

ngx.log(ngx.DEBUG, "host hoanghh" .. host)
ngx.log(ngx.DEBUG, "vao hoanghh ")

local bytes_sent = ngx.var.bytes_sent

Statsd:incr(host .. "_total-requests")

