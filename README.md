#ReadyPool
##Ruby Thread Pool Implementation
###Example
```ruby
require 'ready_pool'
require 'async_emitter'

emitter = AsyncEmitter.new

emitter.on :data, lambda { |data| puts "emitted #{data}" }

rp = ReadyPool.new 10, Proc.new { |data| emitter.emit :data, data }

20.times do |i|
	rp.start i
end

gets #waits for keypress 

rp.kill_all

```


