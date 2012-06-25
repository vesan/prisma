require 'spec_helper'

describe Prisma do
  # storing default values before and re-applying after
  SAVE_AND_RESTORE_CLASS_VARIABLES = [:groups, :redis, :redis_namespace]
  before do
    Prisma.class_variable_set(:@@namespaced_redis, nil)
    SAVE_AND_RESTORE_CLASS_VARIABLES.each do |variable|
      instance_variable_set("@__#{variable}", Prisma.class_variable_get("@@#{variable}"))
    end
  end
  after do
    SAVE_AND_RESTORE_CLASS_VARIABLES.each do |variable|
      Prisma.class_variable_set("@@#{variable}", instance_variable_get("@__#{variable}"))
    end
  end

  describe 'attributes' do
    context 'default value for' do
      subject { Prisma }

      its(:groups) { should == {} }
      its(:redis) { should be_kind_of Redis::Namespace }
      its(:redis_namespace) { should == 'prisma' }
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

      before do
        Prisma.setup do |config|
          config.redis = redis_stub
          config.redis_namespace = redis_namespace_stub
        end
      end
      subject { Prisma }

      it('redis') { subject.class_variable_get(:@@redis).should == redis_stub }
      it('redis_namespace') { subject.class_variable_get(:@@redis_namespace).should == redis_namespace_stub }
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
end

