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
  end
end

