# encoding: utf-8
require 'rubygems'
require 'rspec'
require 'mongoid'
require 'mongoid_max_denormalize'

#
# Fake App
#
MODELS = File.join(File.dirname(__FILE__), "app/models")
$LOAD_PATH.unshift(MODELS)

# Autoload every model for the test suite that sits in spec/app/models.
Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

module Rails
  class Application
  end
end

module MyApp
  class Application < Rails::Application
  end
end



# Are we in presence of Mongoid 3
def mongoid3
  Mongoid::VERSION =~ /\A3\./
end

# When testing locally we use the database named mongoid_max_denormalize_test.
# However when tests are running in parallel on Travis we need to use different
# database names for each process running since we do not have transactions and
# want a clean slate before each spec run.
def database_name
  ENV["CI"] ? "mongoid_max_denormalize_#{Process.pid}" : "mongoid_max_denormalize_test"
end

# Logger
if mongoid3 && !ENV["CI"]
  Moped.logger = Logger.new("log/moped-test.log")
  Moped.logger.level = Logger::DEBUG
end

Mongoid.configure do |config|
  if mongoid3
    config.connect_to(database_name)
  else
    database = Mongo::Connection.new("127.0.0.1", 27017).db(database_name)
    database.add_user("mongoid", "test")
    config.master = database
    config.logger = nil
  end
end


RSpec.configure do |config|

  config.before(:suite) do
    puts "#\n# Mongoid #{Mongoid::VERSION}\n#"
  end

  # Drop all collections and clear the identity map before each spec.
  config.before(:each) do
    Moped.logger.info("\n  ### " << example.full_description) if mongoid3 && !ENV["CI"]

    Mongoid.purge!
    Mongoid::IdentityMap.clear
  end

  # On travis we are creating many different databases on each test run. We
  # drop the database after the suite.
  config.after(:suite) do
    if ENV["CI"]
      if mongoid3
        Mongoid::Threaded.sessions[:default].drop
      else
        Mongoid.master.connection.drop_database(database_name)
      end
    end
  end

end
