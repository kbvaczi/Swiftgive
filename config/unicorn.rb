## SETUP file for unicorn webserver

preload_app true

# determine how long a connection has before timing out.
timeout 30

# the number of unicorn processes running on each dyno.
worker_processes 3

# our sidekick worker
@sidekiq_pid = nil

rails_env = ENV['RAILS_ENV'] || 'development'

listen 3000 if rails_env == 'development'

before_fork do |server, worker|

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')    
  end

  unless @sidekiq_pid.present?
    Rails.logger.info 'Starting Sidekiq Process'
    @sidekiq_pid ||= spawn("bundle exec sidekiq -C ./config/sidekiq.yml")
  end

end

after_fork do |server, worker|

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

end