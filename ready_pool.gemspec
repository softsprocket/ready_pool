Gem::Specification.new do |s|
	s.name        = 'ready_pool'
	s.version     = '1.1.1'
	s.date        = '2015-04-27'
	s.summary     = "ReadyPool"
	s.description = "A thread pool implementation for ruby"
	s.authors     = ["Greg Martin"]
	s.email       = 'greg@softsprocket.com'
	s.files       = ["lib/ready_pool.rb"]
	s.homepage    = 'http://rubygems.org/gems/ready_pool.rb'
	s.license     = 'MIT'
	s.add_runtime_dependency "async_emitter", '~> 1.1', '>= 1.1.1'
end

