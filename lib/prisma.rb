require 'bundler/setup'
Bundler.require(:default)

require 'prisma/railtie'
require 'prisma/filter'

module Prisma
  mattr_reader :groups
  @@groups = {}

  mattr_accessor :redis
  @@redis = Redis.new

  mattr_accessor :redis_namespace
  @@redis_namespace = 'prisma'

  mattr_accessor :redis_expiration_duration

  def self.setup
    yield self
    store_configuration
  end

  def self.group(name, &block)
    @@groups[name] = block
  end

  def self.redis
    @@namespaced_redis ||= Redis::Namespace.new(redis_namespace, :redis => @@redis)
  end

  def self.redis_key(group_name)
    "#{group_name}:#{Time.now.utc.strftime('%Y:%m:%d')}"
  end

  def self.redis_expire(duration=nil)
    duration = redis_expiration_duration unless duration
    (Time.now.utc.beginning_of_day + duration).to_i - Time.now.utc.to_i
  end

  def self.store_configuration
    redis.del 'configuration'
    groups.keys.each do |key|
      redis.rpush 'configuration', key
    end
  end
end

