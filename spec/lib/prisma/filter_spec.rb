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
    render :nothing => true
  end
end

describe TestController, :type => :controller do
  before(:each) do
    Prisma.setup do |config|
      config.redis = REDIS
    end
  end

  it 'calls prisma_disperse_request when requesting an action' do
    controller.should_receive(:prisma_disperse_request)
    get :index
  end

  it 'calls the block of each group' do
    group1_spy = stub(:assert! => nil)
    group2_spy = stub(:assert! => nil)
    Prisma.setup do |config|
      config.group(:group1) { group1_spy.assert! }
      config.group(:group2) { group2_spy.assert! }
    end

    group1_spy.should_receive(:assert!)
    group2_spy.should_receive(:assert!)
    get :index
  end

  context 'redis' do
    before(:all) do
      Timecop.freeze(Time.now)
    end
    after(:all) do
      Timecop.return
    end

    context 'on first request' do
      before do
        Prisma.setup do |config|
          config.group(:by_user_id) { 1 }
        end
      end

      it 'creates a redis hash' do
        expect do
          get :index
        end.to change { Prisma.redis.type Prisma.redis_key(:by_user_id) }.from('none').to('hash')
      end

      it 'adds a key named 1' do
        expect do
          get :index
        end.to change { Prisma.redis.hkeys Prisma.redis_key(:by_user_id) }.from([]).to(['1'])
      end

      it 'sets the counter to 1' do
        get :index
        Prisma.redis.hget(Prisma.redis_key(:by_user_id), '1').should == '1'
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
    end

    context 'on subsequent requests' do
      before do
        Prisma.setup do |config|
          config.group(:by_user_id) { 1 }
        end
        3.times { get :index }
      end

      it 'sets the counter to 4 on fourth call' do
        get :index
        Prisma.redis.hget(Prisma.redis_key(:by_user_id), '1').should == '4'
      end
    end

    it 'uses one key for each day and group' do
      Prisma.setup do |config|
        config.group(:by_user_id) { 1 }
        config.group(:by_client_id) { 1 }
      end

      puts Prisma.redis.keys

      expect do
        get :index
      end.to change { Prisma.redis.keys.count }.by(2)

      Timecop.freeze(Date.yesterday)

      expect do
        get :index
      end.to change { Prisma.redis.keys.count }.by(2)
    end
  end
end

