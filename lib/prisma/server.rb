require 'sinatra/base'
require 'erb'
require 'prisma'
require 'active_support/core_ext'

module Prisma
  # Sinatra application for viewing request stats
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
      Prisma.redis.lrange('configuration', 0, -1).map do |name|
        type = Prisma.redis.get("configuration:type:#{name}").to_sym
        description = Prisma.redis.get("configuration:description:#{name}")
        Prisma::Group.new(name: name, type: type, description: description)
      end
    end
  end
end

