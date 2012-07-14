module Prisma
  # Default logger which acts like a black hole
  class NullLogger
    # Responds to everything, does nothing and returns nil
    def method_missing(method, *args, &block)
    end
  end
end

