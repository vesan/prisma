require 'spec_helper'

module Test
  class Application < Rails::Application
    routes.draw { resources :test }
  end
end

class TestController < ActionController::Base
  include Rails.application.routes.url_helpers
  include Prisma::Filter

  def index
    render nothing: true
  end
end

describe TestController, type: :controller do
  it 'calls prisma_disperse_request when requesting an action' do
    controller.should_receive(:prisma_disperse_request)
    get :index
  end

  it 'calls the block of each group' do
    group1_spy = stub(assert!: nil)
    group2_spy = stub(assert!: nil)
    Prisma.setup do |config|
      config.group(:group1) { group1_spy.assert! }
      config.group(:group2) { group2_spy.assert! }
    end

    group1_spy.should_receive(:assert!)
    group2_spy.should_receive(:assert!)
    get :index
  end

  context 'redis keys' do
    before do
      Prisma.setup do |config|
        config.group(:by_user_id, type: :counter) { 1 }
      end
      Timecop.freeze(Time.now.utc.beginning_of_day)
    end
    after { Timecop.return }

    it 'creates a redis key' do
      expect do
        get :index
      end.to change { Prisma.redis.exists Prisma.redis_key(:by_user_id) }.from(false).to(true)
    end

    it 'uses one key for each day and group' do
      Prisma.setup do |config|
        config.group(:by_user_id) { 1 }
        config.group(:by_client_id) { 1 }
      end

      expect do
        get :index
      end.to change { Prisma.redis.keys.count }.by(2)

      Timecop.freeze(Date.yesterday) do
        expect do
          get :index
        end.to change { Prisma.redis.keys.count }.by(2)
      end
    end

    context 'expiring keys' do
      before do
        Prisma.setup do |config|
          config.redis_expiration_duration = 1.day
        end
      end

      it 'sets key expire to 1 day' do
        expect do
          get :index
        end.to change { Prisma.redis.ttl Prisma.redis_key(:by_user_id) }.from(-1).to(1.day)
      end
    end
  end

  context 'redis counters' do
    before do
      Prisma.setup do |config|
        config.group(:by_user_id) { 1 }
      end
    end

    it 'sets the counter to 1 on first request' do
      get :index
      Prisma.redis.get(Prisma.redis_key(:by_user_id)).should == '1'
    end

    it 'skips incrementing when given block returns false' do
      Prisma.setup do |config|
        config.group(:by_user_id) { false }
      end

      expect do
        get :index
      end.to_not change { Prisma.redis.keys.count }
    end

    it 'skips incrementing when given block returns nil' do
      Prisma.setup do |config|
        config.group(:by_user_id) { nil }
      end

      expect do
        get :index
      end.to_not change { Prisma.redis.keys.count }
    end

    it 'sets the counter to 4 on fourth call' do
      3.times { get :index }
      get :index
      Prisma.redis.get(Prisma.redis_key(:by_user_id)).should == '4'
    end
  end

  context 'redis bitmaps' do
    before do
      Prisma.setup do |config|
        config.group(:by_user_id, :type => :bitmap) { 15 }
      end
      Prisma.stub(:redis_key => 'key')
    end

    it 'sets the byte at the index of the returned int to 1' do
      Redis::Namespace::COMMANDS.stub(:include? => false)
      Prisma.redis.should_receive(:setbit).with('prisma:key', 15, 1)
      get :index
    end

    it 'skips adding namespace if redis_namespace supports setbit' do
      Redis::Namespace::COMMANDS.stub(:include? => true)
      Prisma.redis.should_receive(:setbit).with('key', 15, 1)
      get :index
    end

    it 'skips setting bits when given block returns 0' do
      Prisma.setup do |config|
        config.group(:by_user_id, :type => :bitmap) { 0 }
      end
      expect do
        get :index
      end.to_not change { Prisma.redis.keys.count }
    end

    it 'skips setting bits when given block returns nil' do
      Prisma.setup do |config|
        config.group(:by_user_id, :type => :bitmap) { nil }
      end
      expect do
        get :index
      end.to_not change { Prisma.redis.keys.count }
    end
  end
end

