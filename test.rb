#!/usr/bin/ruby

require 'ready_pool'
require 'async_emitter'

emitter = AsyncEmitter.new

emitter.on :data, lambda { |data| puts "emitted #{data}" }

rp = ReadyPool.new 10, Proc.new { |data| emitter.emit :data, data }

20.times do |i|
	rp.start i
end

gets

rp.kill_all


