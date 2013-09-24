$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "exception_logger/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "exception_logger"
  s.version     = ExceptionLogger::VERSION
  s.authors     = ["Ryan Cheung"]
  s.email       = ["ryancheung.go@gmail.com"]
  s.homepage    = "https://github.com/ryancheung/exception_logger"
  s.summary     = "Log exceptions inside a database table. No avaliable with rails 3.2.x."
  s.description = "It's evolved from the outdated version 0.11.1 and built with rails engine and is mountable."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  # s.add_dependency "jquery-rails"

  s.add_dependency 'will_paginate', '~> 3.0'
  s.add_development_dependency "sqlite3"
end
