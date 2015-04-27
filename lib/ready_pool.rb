require 'thread'

########################################################################
# thread pool implementation
#
# In the example 10 threads are prepared to run the Proc passed as the 
# second argument. If more are needed they are spun up when required.
# When a thread completes its task it returns itself to the pool.
#
# The start method passes its argument to the thread Proc.
#
# ==Example
# 	
#	require 'ready_pool'
#	require 'async_emitter'
#
#	emitter = AsyncEmitter.new
#
#	emitter.on :data, lambda { |data| puts "emitted #{data}" }
#
#	rp = ReadyPool.new 10, Proc.new { |data| emitter.emit :data, data }
#
#	20.times do |i|
#		rp.start i
#	end
#
#	gets #wait for user input
#
#	rp.kill_all
#
########################################################################

class ReadyPool

	################################################################
	# ReadyPool constructor
	#
	# @param num_threads [FixedNum] initial number of threads
	# @param procedure [Proc] called when start method is called
	################################################################
	def initialize (num_threads, procedure)
		@procedure = procedure
		@pool_semaphore = Mutex.new
		@pool_condition = ConditionVariable.new
		@pool = []

		@pool_semaphore.synchronize do
			num_threads.times do |i|
				@pool[i] = new_thread
				@pool[i][:ready] = false
				
				@pool[i][:thread] = Thread.new do 
					thread_proc @pool[i]
				end

				@pool_condition.wait @pool_semaphore

			end
		end
	end

	################################################################
	# starts the thread
	#
	# @param data [Object] data passed to the thread Proc
	################################################################
	def start data
		th = nil
		@pool_semaphore.synchronize do
			th = @pool.shift
		end

		if th == nil
			th = new_thread
			th[:ready] = false
			th[:thread] = Thread.new do
				thread_proc th
			end
				
			@pool_semaphore.synchronize do
				@pool_condition.wait @pool_semaphore
			end
		end

		th[:data] = data
		signal_thread th	
	end

	################################################################
	# kills all threads
	################################################################
	def kill_all
		@pool.each do |th|
			Thread.kill th[:thread]
		end
		@pool = []
	end

	protected
	def thread_proc (th)
		while true
			th[:semaphore].synchronize do

				@pool_semaphore.synchronize do
					@pool_condition.signal
				end

				th[:cv].wait th[:semaphore]
				@procedure.call th[:data]
				@pool_semaphore.synchronize do
					@pool.push th
				end	
				
			end
		end
	end

	def new_thread
		th = {}
		th[:semaphore] = Mutex.new
		th[:cv] = ConditionVariable.new
		return th
	end

	def signal_thread (th)
		th[:semaphore].synchronize do
			th[:cv].signal
		end
	end
end

