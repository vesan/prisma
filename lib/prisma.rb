require 'rails/all'
require 'redis-namespace'

require 'prisma/group'
require 'prisma/railtie'
require 'prisma/filter'

module Prisma
  mattr_reader :groups
  @@groups = {}

  mattr_accessor :redis
  @@redis = ::Redis.new

  mattr_accessor :redis_namespace
  @@redis_namespace = 'prisma'

  mattr_accessor :redis_expiration_duration

  def self.setup
    yield self
    store_configuration
  end

  def self.group(name, description=nil, &block)
    @@groups[name] = Group.new(:name => name, :description => description, :block => block)
  end

  def self.redis
    @@namespaced_redis ||= lambda do
      case @@redis
      when String
        if @@redis =~ /redis\:\/\//
          redis = Redis.connect(:url => @@redis, :thread_safe => true)
        else
          host, port, db = @@redis.split(':')
          redis = Redis.new(:host => host, :port => port, :thread_safe => true, :db => db)
        end
        Redis::Namespace.new(redis_namespace, :redis => redis)
      else
        Redis::Namespace.new(redis_namespace, :redis => @@redis)
      end
    end.call
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
    groups.values.each do |group|
      redis.hset 'configuration', group.name, group.description
    end
  end
end

