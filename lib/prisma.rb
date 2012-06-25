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

  def self.setup
    yield self
  end

  def self.group(name, &block)
    groups[:name] = block
  end

  def self.redis
    @@namespaced_redis ||= Redis::Namespace.new(redis_namespace, :redis => @@redis)
  end
end

