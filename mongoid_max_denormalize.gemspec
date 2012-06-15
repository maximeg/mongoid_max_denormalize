$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "mongoid/max/denormalize/version"

Gem::Specification.new do |s|
  s.name        = "mongoid_max_denormalize"
  s.version     = Mongoid::Max::Denormalize::Version::STRING
  s.date        = Time.now.strftime("%Y-%m-%d")

  s.authors     = ["Maxime Garcia"]
  s.email       = ["maxime.garcia@maxbusiness.fr"]

  s.summary     = "MaxMapper, polyvalent ORM for Rails"
  s.homepage    = "http://github.com/maximeg/mongoid_max_denormalize"

  s.files       = %w( README.md LICENSE )
  s.files      += Dir.glob("lib/**/*")
  s.require_paths = ["lib"]
  s.test_files  = Dir.glob("spec/**/*")
  s.has_rdoc    = false

  s.add_dependency "mongoid", ">= 2.4"
  s.add_dependency "activesupport", "~> 3.1"

  s.add_development_dependency "rspec", "~> 2.9"
  s.add_development_dependency "guard-rspec"

  s.description = <<description
    Mongoid::Max::Denormalize is a denormalization extension for Mongoid.
description
end

