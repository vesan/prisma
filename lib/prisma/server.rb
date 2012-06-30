require 'sinatra/base'
require 'erb'
require 'prisma'

module Prisma
  class Server < Sinatra::Base
    dir = File.join(File.dirname(File.expand_path(__FILE__)), 'server')

    set :views, File.join(dir, 'views')
    set :public_folder, File.join(dir, 'public')

    get '/' do
      redirect to('/daily')
    end

    get '/daily' do
      @groups = Prisma.redis.lrange('configuration', 0, -1).map do |group_name|
        group = Prisma::Group.new(:name => group_name)
        values = group.range((Date.today-30)...Date.today)
        [group, values]
      end
      erb :index
    end

    get '/weekly' do
      @groups = Prisma.redis.lrange('configuration', 0, -1).map do |group_name|
        group = Prisma::Group.new(:name => group_name)
        values = group.range((Date.today-30)...Date.today)
        [group, values]
      end
      erb :index
    end

    get '/monthly' do
      @groups = Prisma.redis.lrange('configuration', 0, -1).map do |group_name|
        group = Prisma::Group.new(:name => group_name)
        values = group.range((Date.today-30)...Date.today)
        [group, values]
      end
      erb :index
    end
  end
end

