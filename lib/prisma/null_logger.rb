module Prisma
  class NullLogger
    def method_missing(method, *args, &block)
      puts "method missing"
    end
  end
end

