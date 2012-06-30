require 'spec_helper'

describe Prisma::Group do
  let(:group_name) { :test_group }

  def set_hits(date, count)
    count.times do |n|
      Prisma.redis.hset Prisma.redis_key(group_name, date), n, 1
    end
  end

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
    let(:group) { Prisma::Group.new(:name => group_name) }

    it 'returns a hash' do
      group.range(range).should be_kind_of Hash
    end

    it 'is also accessible via #daily' do
      group.daily(range).should be_kind_of Hash
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
        set_hits(Date.new(2012, 06, 1), 3)
        set_hits(Date.new(2012, 06, 2), 1)
        set_hits(Date.new(2012, 06, 3), 2)
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

  describe '#weekly' do
    let(:range) { Date.new(2012, 06, 18)..Date.new(2012, 07, 01) }
    let(:group) { Prisma::Group.new(:name => group_name) }

    before do
      Timecop.freeze(Time.now)
      set_hits(Date.new(2012, 06, 17), 1)
      set_hits(Date.new(2012, 06, 18), 2)
      set_hits(Date.new(2012, 06, 25), 1)
      set_hits(Date.new(2012, 06, 26), 1)
      set_hits(Date.new(2012, 07, 01), 1)
    end
    after { Timecop.return }

    it 'groups counts by week' do
      group.weekly(range).should == {
        Date.new(2012, 06, 18) => 2,
        Date.new(2012, 06, 25) => 3
      }
    end
  end

  describe '#monthly' do
    let(:range) { Date.new(2012, 05, 01)..Date.new(2012, 06, 01) }
    let(:group) { Prisma::Group.new(:name => group_name) }

    before do
      Timecop.freeze(Time.now)
      set_hits(Date.new(2012, 04, 17), 1)
      set_hits(Date.new(2012, 05, 18), 2)
      set_hits(Date.new(2012, 05, 25), 1)
      set_hits(Date.new(2012, 05, 26), 1)
      set_hits(Date.new(2012, 06, 01), 1)
      set_hits(Date.new(2012, 07, 01), 1)
    end
    after { Timecop.return }

    it 'groups counts by month' do
      group.monthly(range).should == {
        Date.new(2012, 05, 01) => 4,
        Date.new(2012, 06, 01) => 1
      }
    end
  end
end

