require 'sinatra/base'
require 'erb'
require 'prisma'

module Prisma
  class Server < Sinatra::Base
    dir = File.join(File.dirname(File.expand_path(__FILE__)), 'server')

    set :views, File.join(dir, 'views')
    set :public_folder, File.join(dir, 'public')

    get '/' do
      erb :index
    end
  end
end

