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
      @groups = groups.map do |group|
        values = group.daily (Date.today-1.month)..Date.today
        [group, values]
      end
      erb :index
    end

    get '/weekly' do
      @date_format = '%W'
      @groups = groups.map do |group|
        values = group.weekly (Date.today-3.months)..Date.today
        [group, values]
      end
      erb :index
    end

    get '/monthly' do
      @date_format = '%Y-%m'
      @groups = groups.map do |group|
        values = group.monthly (Date.today-1.year)..Date.today
        [group, values]
      end
      erb :index
    end

    private

    def groups
      Prisma.redis.hgetall('configuration').map do |name, description|
        Prisma::Group.new(:name => name, :description => description)
      end
    end
  end
end

