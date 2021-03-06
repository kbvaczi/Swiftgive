require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'],
                   :size => 1,
                   :namespace => 'sidekiq' }
end

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDISTOGO_URL'],
                   :size => 5,
                   :namespace => 'sidekiq' }  
end