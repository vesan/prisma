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
  it 'calls prisma_disperse_request when requesting an action' do
    controller.should_receive(:prisma_disperse_request)
    get :index
  end
end

