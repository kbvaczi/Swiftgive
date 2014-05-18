Devise::Async.setup do |config|
	# Supported options: :resque, :sidekiq, :delayed_job, :queue_classic
	config.backend = :sidekiq
	config.queue   = :email
end