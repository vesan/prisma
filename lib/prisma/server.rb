require 'sinatra/base'
require 'erb'
require 'prisma'
require 'active_support/core_ext'

module Prisma
  class Server < Sinatra::Base
    dir = File.join(File.dirname(File.expand_path(__FILE__)), 'server')

    set :views, File.join(dir, 'views')
    set :public_folder, File.join(dir, 'public')

    get '/' do
      redirect to('/daily')
    end

    get '/daily' do
      @date_format = '%m-%d'
      @groups = Prisma.redis.lrange('configuration', 0, -1).map do |group_name|
        group = Prisma::Group.new(:name => group_name)
        values = group.daily (Date.today-1.month)..Date.today
        [group, values]
      end
      erb :index
    end

    get '/weekly' do
      @date_format = '%W'
      @groups = Prisma.redis.lrange('configuration', 0, -1).map do |group_name|
        group = Prisma::Group.new(:name => group_name)
        values = group.weekly (Date.today-3.months)..Date.today
        [group, values]
      end
      erb :index
    end

    get '/monthly' do
      @date_format = '%Y-%m'
      @groups = Prisma.redis.lrange('configuration', 0, -1).map do |group_name|
        group = Prisma::Group.new(:name => group_name)
        values = group.monthly (Date.today-1.year)..Date.today
        [group, values]
      end
      erb :index
    end
  end
end

