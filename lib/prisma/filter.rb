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

        case group.type
        when :bitmap
          next if value.to_i == 0
          setbit_key = Redis::Namespace::COMMANDS.include?('setbit') ? redis_key : "#{Prisma.redis_namespace}:#{redis_key}"
          Prisma.redis.setbit setbit_key, value.to_i, 1
        when :counter
          next unless value
          Prisma.redis.incr redis_key
        end
        Prisma.redis.expire redis_key, Prisma.redis_expire if Prisma.redis_expiration_duration
      end
    end
  end
end

