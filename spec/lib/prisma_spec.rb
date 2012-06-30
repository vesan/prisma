require 'spec_helper'

describe Prisma do
  describe 'attributes' do
    context 'default value for' do
      subject { Prisma }

      its(:groups) { should == {} }
      its(:redis) { should be_kind_of Redis::Namespace }
      its(:redis_namespace) { should == 'prisma' }
      its(:redis_expiration_duration) { should be_nil }
    end
  end

  describe '#setup' do
    it 'block yields itself' do
      Prisma.setup do |config|
        config.should == Prisma
      end
    end

    context 'allows to overwrite attribute' do
      let(:redis_stub) { stub }
      let(:redis_namespace_stub) { stub }
      let(:redis_expiration_duration_stub) { stub }

      before do
        Prisma.setup do |config|
          config.redis = redis_stub
          config.redis_namespace = redis_namespace_stub
          config.redis_expiration_duration = redis_expiration_duration_stub
        end
      end
      subject { Prisma }

      it('redis') { subject.class_variable_get(:@@redis).should == redis_stub }
      it('redis_namespace') { subject.class_variable_get(:@@redis_namespace).should == redis_namespace_stub }
      it('redis_expiration_duration') { subject.class_variable_get(:@@redis_expiration_duration).should == redis_expiration_duration_stub }
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

  describe '#redis' do
    it 'returns Redis::Namespace instance' do
      Prisma.redis.should be_kind_of Redis::Namespace
    end

    it 'returns instance with default namespace' do
      Prisma.setup do |config|
        config.redis_namespace = 'asdf'
      end
      Prisma.redis.namespace.should == 'asdf'
    end
  end

  describe '#redis_key' do
    it 'returns a string with the group name and todays date' do
      Timecop.freeze(Time.parse('2012-06-27T00:00:00Z')) do
        Prisma.redis_key(:my_group).should == 'my_group:2012:06:27'
      end
    end
  end

  describe '#redis_expire_at' do
    it 'returns integer value of today + given duration' do
      Timecop.freeze(Time.parse('2012-06-27T00:00:00Z')) do
        Prisma.redis_expire(1.day).should == 1.day.to_i
      end
    end
  end
end

