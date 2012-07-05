module Prisma
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
        Prisma.redis.hincrby redis_key, value, 1 if value

        Prisma.redis.expire redis_key, Prisma.redis_expire if Prisma.redis_expiration_duration
      end
    end
  end
end

