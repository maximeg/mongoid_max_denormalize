# encoding: utf-8
require 'rubygems'
require 'rspec'
require 'mongoid'
require 'mongoid_max_denormalize'
require 'logger'

Mongoid.configure do |config|
  config.connect_to('mongoid_max_denormalize_test')
end

Mongoid.logger = Logger.new("log/mongoid-test.log")
Mongoid.logger.level = Logger::DEBUG
Moped.logger = Logger.new("log/moped-test.log")
Moped.logger.level = Logger::DEBUG

RSpec.configure do |config|

  # Drop all collections and clear the identity map before each spec.
  config.before(:each) do
    Moped.logger.info("\n  ### " << example.full_description)

    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end

end

