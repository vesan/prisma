require 'spec_helper'

describe Prisma::NullLogger do
  it 'responds to every method' do
    expect do
      Prisma::NullLogger.new.send("method_#{rand(100)}")
    end.to_not raise_error
  end
end

