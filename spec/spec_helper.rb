require 'bundler/setup'
Bundler.require(:default, :development, :test)

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rails/all'
require 'rspec/rails'
require 'prisma'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true  

  # storing default values before and re-applying after
  SAVE_AND_RESTORE_CLASS_VARIABLES = [:groups, :redis, :redis_namespace]
  config.before(:suite) do
    default_values = {}
    SAVE_AND_RESTORE_CLASS_VARIABLES.each do |variable|
      default_values[variable] = Prisma.class_variable_get("@@#{variable}").dup
    end

    DEFAULT_VALUES = default_values
    REDIS = Redis.new(:db => 1)
  end
  config.before(:each) do
    # always use redis db 1 for tests
    Redis.stub(:new => REDIS)
    REDIS.flushdb

    DEFAULT_VALUES.each do |variable, value|
      Prisma.class_variable_set("@@#{variable}", value.dup)
    end
    Prisma.class_variable_set(:@@namespaced_redis, nil)
  end
end

