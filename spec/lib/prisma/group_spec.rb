require 'spec_helper'

describe Prisma::Group do
  let(:group_name) { :test_group }

  def set_count_hits(date, count)
    Prisma.redis.set Prisma.redis_key(group_name, date), count
  end
  
  def set_bitmap_hit(date, user_id)
    redis_key = Prisma.redis_key(group_name, date)
    setbit_key = Redis::Namespace::COMMANDS.include?('setbit') ? redis_key : "#{Prisma.redis_namespace}:#{redis_key}"
    Prisma.redis.setbit setbit_key, user_id, 1
  end

  describe '#initialize' do
    context 'sets attributes from hash' do
      let(:name_stub) { stub }
      let(:type) { :bitmap }
      let(:description_stub) { stub }
      let(:block_stub) { stub }

      subject { Prisma::Group.new(name: name_stub,
                                  type: type,
                                  description: description_stub,
                                  block: block_stub) }
      its(:name) { should == name_stub }
      its(:type) { should == type }
      its(:description) { should == description_stub }
      its(:block) { should == block_stub }

      it 'uses :counter as default type' do
        Prisma::Group.new.type.should == :counter
      end

      it 'throws ArgumentError when type is undefined' do
        expect { Prisma::Group.new(type: :undefined_type) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#range' do
    let(:range) { Date.new(2012, 06, 01)..Date.new(2012, 06, 03) }
    let(:group) { Prisma::Group.new(name: group_name) }

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
      context 'when type counter' do
        before do
          set_count_hits(Date.new(2012, 06, 1), 3)
          set_count_hits(Date.new(2012, 06, 2), 1)
          set_count_hits(Date.new(2012, 06, 3), 2)
        end

        it 'returns the counts' do
          group.range(range).should == {
            Date.new(2012, 06, 01) => 3,
            Date.new(2012, 06, 02) => 1,
            Date.new(2012, 06, 03) => 2
          }
        end
      end

      context 'when type bitmap' do
        let(:group) { Prisma::Group.new(name: group_name, type: :bitmap) }

        before do
          set_bitmap_hit(Date.new(2012, 06, 1), 1)
          set_bitmap_hit(Date.new(2012, 06, 2), 1)
          set_bitmap_hit(Date.new(2012, 06, 3), 1)
          set_bitmap_hit(Date.new(2012, 06, 3), 2)
        end

        it 'returns the correct counts' do
          group.range(range).should == {
            Date.new(2012, 06, 01) => 1,
            Date.new(2012, 06, 02) => 1,
            Date.new(2012, 06, 03) => 2
          }
        end
      end
    end
  end

  describe '#weekly' do
    let(:range) { Date.new(2012, 06, 18)..Date.new(2012, 07, 01) }

    context 'when type counter' do
      let(:group) { Prisma::Group.new(name: group_name) }

      before do
        Timecop.freeze(Time.now)
        set_count_hits(Date.new(2012, 06, 17), 1)
        set_count_hits(Date.new(2012, 06, 18), 2)
        set_count_hits(Date.new(2012, 06, 25), 1)
        set_count_hits(Date.new(2012, 06, 26), 1)
        set_count_hits(Date.new(2012, 07, 01), 1)
      end
      after { Timecop.return }

      it 'groups counts by week' do
        group.weekly(range).should == {
          Date.new(2012, 06, 18) => 2,
          Date.new(2012, 06, 25) => 3
        }
      end
    end

    context 'when type bitmap' do
      let(:group) { Prisma::Group.new(name: group_name, type: :bitmap) }

      before do
        Timecop.freeze(Time.now)
        set_bitmap_hit(Date.new(2012, 06, 17), 1)
        set_bitmap_hit(Date.new(2012, 06, 18), 1)
        set_bitmap_hit(Date.new(2012, 06, 19), 1)
        set_bitmap_hit(Date.new(2012, 06, 25), 1)
        set_bitmap_hit(Date.new(2012, 06, 26), 1)
        set_bitmap_hit(Date.new(2012, 07, 01), 1)
        set_bitmap_hit(Date.new(2012, 07, 01), 2)
      end
      after { Timecop.return }

      it 'groups counts by week' do
        group.weekly(range).should == {
          Date.new(2012, 06, 18) => 1,
          Date.new(2012, 06, 25) => 2
        }
      end
    end
  end

  describe '#monthly' do
    let(:range) { Date.new(2012, 05, 01)..Date.new(2012, 06, 02) }

    context 'when type counter' do
      let(:group) { Prisma::Group.new(name: group_name) }

      before do
        Timecop.freeze(Time.now)
        set_count_hits(Date.new(2012, 04, 17), 1)
        set_count_hits(Date.new(2012, 05, 18), 2)
        set_count_hits(Date.new(2012, 05, 25), 1)
        set_count_hits(Date.new(2012, 05, 26), 1)
        set_count_hits(Date.new(2012, 06, 01), 1)
        set_count_hits(Date.new(2012, 07, 01), 1)
      end
      after { Timecop.return }

      it 'groups counts by month' do
        group.monthly(range).should == {
          Date.new(2012, 05, 01) => 4,
          Date.new(2012, 06, 01) => 1
        }
      end
    end

    context 'when type bitmap' do
      let(:group) { Prisma::Group.new(name: group_name, type: :bitmap) }

      before do
        Timecop.freeze(Time.now)
        set_bitmap_hit(Date.new(2012, 04, 17), 1)
        set_bitmap_hit(Date.new(2012, 05, 18), 1)
        set_bitmap_hit(Date.new(2012, 05, 25), 1)
        set_bitmap_hit(Date.new(2012, 05, 26), 2)
        set_bitmap_hit(Date.new(2012, 06, 01), 1)
        set_bitmap_hit(Date.new(2012, 06, 02), 1)
        set_bitmap_hit(Date.new(2012, 07, 01), 1)
      end
      after { Timecop.return }

      it 'groups counts by month' do
        group.monthly(range).should == {
          Date.new(2012, 05, 01) => 2,
          Date.new(2012, 06, 01) => 1
        }
      end
    end
  end
end

