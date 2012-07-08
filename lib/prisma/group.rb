module Prisma
  # Represents a configured group, has convenience methods for getting data.
  class Group
    # The name of the group, typically a +Symbol+
    attr_accessor :name

    # The type of the group, +:counter+ or +:bitmap+
    attr_accessor :type

    # The description of the group, typcially a +String+
    attr_accessor :description

    # The block which evaluates to a +String+ or meaningful +Object.to_s+
    attr_accessor :block

    # Initialize +Group+ from a hash
    def initialize(options={})
      options.reverse_merge!(type: :counter)
      raise ArgumentError.new("Type #{options[:type]} not allowed") unless [:counter, :bitmap].include? options[:type]

      self.name = options[:name]
      self.type = options[:type]
      self.description = options[:description]
      self.block = options[:block]
    end

    # Get a +Hash+ with the +Date+ as key and amount of items as the value. Grouped by day.
    #     group.range(5.days.ago.to_date..Date.today)
    #     group.daily(5.days.ago.to_date..Date.today)
    # @param [Range] range of days
    # @return [Hash]
    def range(range)
      range = range..range if range.is_a? Date
      data = {}
      range.each do |date|
        data[date] = Prisma.redis.hlen Prisma.redis_key(name, date)
      end
      data
    end
    alias_method :daily, :range

    # Get a +Hash+ with the +Date+ as key and amount of items as the value. Grouped by week, key represents a +Date+ object of the first day of the week.
    #     group.weekly(1.week.ago.to_date..Date.today)
    # @param [Range] range of days
    # @return [Hash]
    def weekly(range)
      data = range(range)

      data = data.group_by { |date, value| date.beginning_of_week }
      sum_up_grouped_data(data)
    end

    # Get a +Hash+ with the +Date+ as key and amount of items as the value. Grouped by month, key represents a +Date+ object of the first day of the month.
    #     group.monthly(1.month.ago.to_date..Date.today)
    # @param [Range] range of days
    # @return [Hash]
    def monthly(range)
      data = range(range)

      data = data.group_by { |date, value| date.beginning_of_month }
      sum_up_grouped_data(data)
    end

    private

    def sum_up_grouped_data(data)
      data.each do |date, values|
        data[date] = values.map { |value| value.second }.inject{ |sum, count| sum + count }
      end
    end
  end
end

