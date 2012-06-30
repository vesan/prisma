require 'bundler/setup'
Bundler.require(:default)

require 'prisma/group'
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
    @@groups[name] = Group.new(:name => name, :block => block)
  end

  def self.redis
    @@namespaced_redis ||= Redis::Namespace.new(redis_namespace, :redis => @@redis)
  end

  def self.redis_key(group_name, date=nil)
    date = Time.now.utc.to_date unless date
    "#{group_name}:#{date.strftime('%Y:%m:%d')}"
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

