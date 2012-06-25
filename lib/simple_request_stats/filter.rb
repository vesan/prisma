module SimpleRequestStats
  module Filter
    extend ActiveSupport::Concern

    included do
      before_filter :simple_request_stats_collect_request
    end

    protected

    def simple_request_stats_collect_request
      SimpleRequestStats.groups.each do |name, block|
        Rails.logger.info "Executing block for group #{name}"
        value = block.call
        Rails.logger.info "Value from block: #{value}"
      end
    end
  end
end

