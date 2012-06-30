module Prisma
  class Group
    attr_accessor :name, :block

    def initialize(options={})
      self.name = options[:name]
      self.block = options[:block]
    end

    def range(range)
      range = range..range if range.is_a? Date
      data = {}
      range.each do |date|
        data[date] = Prisma.redis.hlen Prisma.redis_key(name, date)
      end
      data
    end
    alias_method :daily, :range

    def weekly(range)
      data = range(range)

      data = data.group_by { |date, value| date.beginning_of_week }
      sum_up_grouped_data(data)
    end

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

