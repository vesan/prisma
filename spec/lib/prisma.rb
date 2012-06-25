require 'spec_helper'

describe Prisma do
  describe '#setup' do
    it 'block yields itself' do
      Prisma.setup do |config|
        config.should == Prisma
      end
    end
  end

  describe '#group' do
    it 'adds a group through setup block' do
      expect do
        Prisma.setup do |config|
          config.group(:by_user_id) { |request| 1 }
        end
      end.to change(Prisma.groups, :count).by(1)
    end
  end
end

