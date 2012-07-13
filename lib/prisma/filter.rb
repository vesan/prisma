module Prisma
  # Gets included into controllers and runs after_filter method
  module Filter
    extend ActiveSupport::Concern

    included do
      after_filter :prisma_disperse_request
    end

    protected

    def prisma_disperse_request
      Prisma.groups.each do |name, group|
        redis_key = Prisma.redis_key(name)
        value = group.block.call(self)
        next unless value

        Prisma.redis.incr redis_key if group.type == :counter
        Prisma.redis.expire redis_key, Prisma.redis_expire if Prisma.redis_expiration_duration
      end
    end
  end
end

