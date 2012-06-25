module SimpleRequestStats
  mattr_accessor :groups
  @@groups = {}

  def self.setup
    yield self
  end

  def self.group(name, &block)
    groups[:name] = block
  end
end

