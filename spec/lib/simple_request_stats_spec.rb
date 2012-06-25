require 'spec_helper'

describe SimpleRequestStats do
  describe '#setup' do
    it 'block yields itself' do
      SimpleRequestStats.setup do |config|
        config.should == SimpleRequestStats
      end
    end
  end

  describe '#group' do
    it 'adds a group through setup block' do
      expect do
        SimpleRequestStats.setup do |config|
          config.group(:by_user_id) { |request| 1 }
        end
      end.to change(SimpleRequestStats.groups, :count).by(1)
    end
  end
end

