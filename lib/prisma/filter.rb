module Prisma
  module Filter
    extend ActiveSupport::Concern

    included do
      before_filter :prisma_disperse_request
    end

    protected

    def prisma_disperse_request
      Prisma.groups.each do |name, block|
        value = block.call(request)
        Prisma.redis.hincrby Prisma.redis_key(name), value, 1 if value
      end
    end
  end
end

