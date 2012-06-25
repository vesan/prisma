module SimpleRequestStats
  class Railtie < Rails::Railtie
    initializer 'simple_request_stats.insert_into_action_controller' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, ::SimpleRequestStats::Filter)
      end
    end
  end
end

