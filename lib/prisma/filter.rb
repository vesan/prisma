module Prisma
  module Filter
    extend ActiveSupport::Concern

    included do
      before_filter :prisma_collect_request
    end

    protected

    def prisma_collect_request
      Prisma.groups.each do |name, block|
        Rails.logger.info "Executing block for group #{name}"
        value = block.call
        Rails.logger.info "Value from block: #{value}"
      end
    end
  end
end

