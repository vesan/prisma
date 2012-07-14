require 'spec_helper'

describe Prisma do
  describe 'attributes' do
    context 'default value for' do
      subject { Prisma }

      its(:groups) { should == {} }
      its(:redis) { should be_kind_of Redis::Namespace }
      its(:redis_namespace) { should == 'prisma' }
      its(:redis_expiration_duration) { should be_nil }
      its(:logger) { should be_kind_of Prisma::NullLogger }
    end
  end

  describe '#setup' do
    it 'block yields itself' do
      Prisma.setup do |config|
        config.should == Prisma
      end
    end

    context 'allows to overwrite attribute' do
      let(:redis_stub) { stub(del: true, rpush: true) }
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

    context 'configuration storage' do
      before do
        Prisma.setup do |config|
          config.group('group1', description: 'description 1') { 1 }
          config.group('group2', type: :bitmap, description: 'description 2') { 1 }
          config.group('group3') { 1 }
        end
      end

      it 'stores group names in configuration list' do
        Prisma.redis.lrange('configuration', 0, -1).should == ['group1',
                                                               'group2',
                                                               'group3']
      end

      it 'stores group descriptions as their own keys' do
        Prisma.redis.get('configuration:description:group1').should == 'description 1'
        Prisma.redis.get('configuration:description:group2').should == 'description 2'
        Prisma.redis.exists('configuration:description:group3').should be_false
      end

      it 'stores group type as their own keys' do
        Prisma.redis.get('configuration:type:group1').should == 'counter'
        Prisma.redis.get('configuration:type:group2').should == 'bitmap'
        Prisma.redis.get('configuration:type:group3').should == 'counter'
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

    it 'should store groups as Group objects' do
      Prisma.setup do |config |
        config.group (:by_user_id) { 1 }
      end
      Prisma.groups[:by_user_id].should be_kind_of Prisma::Group
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

    it 'creates correct Redis object when hostname:port' do
      Redis.should_receive(:new).with(host: 'hostname',
                                      port: 'port',
                                      thread_safe: true,
                                      db: nil)
      Prisma.setup do |config|
        config.redis = 'hostname:port'
      end
    end

    it 'creates correct Redis object when hostname:port:db' do
      Redis.should_receive(:new).with(host: 'hostname',
                                      port: 'port',
                                      thread_safe: true,
                                      db: 'db')
      Prisma.setup do |config|
        config.redis = 'hostname:port:db'
      end
    end

    it 'creates correct Redis object when redis://hostname:port/db' do
      Redis.should_receive(:new).with(host: 'hostname',
                                      port: 'port',
                                      thread_safe: true,
                                      db: 'db')
      Prisma.setup do |config|
        config.redis = 'hostname:port:db'
      end
    end
  end

  describe '#redis_key' do
    it 'returns a string with the group name and todays date' do
      Timecop.freeze(Time.parse('2012-06-27T00:00:00Z')) do
        Prisma.redis_key(:my_group).should == 'my_group:2012:06:27'
      end
    end

    it 'allows to overwrite date' do
      Timecop.freeze(Time.parse('2012-06-27T00:00:00Z')) do
        Prisma.redis_key(:my_group, Date.new(2012, 06, 01)).should == 'my_group:2012:06:01'
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

