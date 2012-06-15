# encoding: utf-8
require 'rubygems'
require 'rspec'
require 'mongoid'
require 'mongoid_max_denormalize'

# When testing locally we use the database named mongoid_max_denormalize_test.
# However when tests are running in parallel on Travis we need to use different
# database names for each process running since we do not have transactions and
# want a clean slate before each spec run.
def database_name
  ENV["CI"] ? "mongoid_max_denormalize_#{Process.pid}" : "mongoid_max_denormalize_test"
end

# Logger
unless ENV["CI"]
  Moped.logger = Logger.new("log/moped-test.log")
  Moped.logger.level = Logger::DEBUG
end

Mongoid.configure do |config|
  config.connect_to(database_name)
end


RSpec.configure do |config|

  # Drop all collections and clear the identity map before each spec.
  config.before(:each) do
    Moped.logger.info("\n  ### " << example.full_description) unless ENV["CI"]

    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end

  # On travis we are creating many different databases on each test run. We
  # drop the database after the suite.
  config.after(:suite) do
    if ENV["CI"]
      Mongoid::Threaded.sessions[:default].drop
    end
  end

end

