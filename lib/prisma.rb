module Prisma
  mattr_reader :groups
  @@groups = {}

  def self.setup
    yield self
  end

  def self.group(name, &block)
    groups[:name] = block
  end
end

