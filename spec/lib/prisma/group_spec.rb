require 'spec_helper'

describe Prisma::Group do
  describe '#initialize' do
    context 'sets attributes from hash' do
      let(:name_stub) { stub }
      let(:block_stub) { stub }

      subject { Prisma::Group.new(:name => name_stub, :block => block_stub) }
      its(:name) { should == name_stub }
      its(:block) { should == block_stub }
    end
  end

  describe '#range' do
    let(:range) { Date.new(2012, 06, 01)..Date.new(2012, 06, 03) }
    let(:group_name) { :test_group }
    let(:group) { Prisma::Group.new(:name => group_name) }

    it 'returns a hash' do
      group.range(range).should be_kind_of Hash
    end

    context 'when no data is available' do
      it 'returns a hash with count values 0' do
        group.range(range).should == {
          Date.new(2012, 06, 01) => 0,
          Date.new(2012, 06, 02) => 0,
          Date.new(2012, 06, 03) => 0
        }
      end
    end

    context 'when data is available' do
      before do
        Prisma.redis.hmset Prisma.redis_key(group_name, Date.new(2012, 06, 1)),
          1, 1,
          2, 1,
          3, 1
        Prisma.redis.hmset Prisma.redis_key(group_name, Date.new(2012, 06, 2)),
          1, 1
        Prisma.redis.hmset Prisma.redis_key(group_name, Date.new(2012, 06, 3)),
          1, 1,
          2, 1
      end

      it 'returns the counts' do
        group.range(range).should == {
          Date.new(2012, 06, 01) => 3,
          Date.new(2012, 06, 02) => 1,
          Date.new(2012, 06, 03) => 2
        }
      end
    end
  end
end

