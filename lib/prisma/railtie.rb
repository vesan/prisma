module Prisma
  class Railtie < Rails::Railtie
    initializer 'prisma.insert_into_action_controller' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, ::Prisma::Filter)
      end
    end
  end
end

