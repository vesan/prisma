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
      end
    end
  end
end

