source 'https://rubygems.org'
source 'https://rails-assets.org'

ruby '2.0.0'

gem 'rails', '3.2.12'

gem 'mobylette', '~> 3.3.2'                           # adds mobile mime type and ability to display separate mobile views

gem 'devise', '~> 2.2.3'                              # User Authentication
gem 'omniauth', '~> 1.1.3'                            # omni-auth implementation for signing in from third party services (facebook, google, etc...)
gem 'omniauth-facebook', '~> 1.4.1'                   # omni-auth plugin for logging in from facebook
gem 'omniauth-google-oauth2', '~> 0.1.13'             # omni-auth strategy for logging in with google
gem 'omniauth-linkedin', '~> 0.1.0'                   # omni-auth strategy for logging in with linkedin

gem 'sidekiq', '~> 2.6.1'                             # redis backed background processing
gem 'sidekiq-unique-jobs', '~> 3.0.0'                 # adds unique jobs functionality to sidekiq
gem 'devise-async', '~> 0.6.0'                        # devise emails sent in background

gem 'honeypot-captcha', '~> 0.0.2'                    # alternative to capcha without the complexity 
gem 'simple_form', '~> 2.1.0'                         # standardized form CSS and helpers
gem 'client_side_validations', '~> 3.2.6'
gem 'client_side_validations-simple_form', '~> 2.1.0' # client-side validations plugin to use simple form CSS

gem 'rqrcode', '~> 0.4.2'                             # QRCode Generator Library
gem 'imgkit', '~> 1.3.9'                              # convert html to images
gem 'pdfkit', '~> 0.6.2'
gem 'wkhtmltopdf-binary', '~> 0.9.9.1'
gem 'carrierwave', '~> 0.8'                           # image_scan uploader
gem 'fog', '~> 1.10'                                  # supports amazon s3
gem 'unf'                                             # uniform normalization form support required for fog gem now?
gem 'mini_magick', '~> 3.6'                           # image manipulation

gem 'carmen', '~> 1.0.1'                              # State and country information
gem 'unicorn'                                         # Multi-threaded web server

gem 'sitemap_generator', '~> 5.0.4'                   # generates a sitemap and advertises new sitemaps to bing and google search

group :development do
  gem 'unicorn-rails', '~> 2.1.1'                     # unicorn works with "rails s"
  gem 'sqlite3'                                       # simple file-based database
  gem 'slim'                                          # this is for sidekiq monitoring server 
  gem 'sinatra', :require => nil                      # this is for sidekiq monitoring server
end

group :production, :staging do
  gem 'activerecord-postgresql-adapter'               # PostgesQL Adapter for Heroku Database (requires Postgres to be installed, heroku has it pre-installed)
  gem 'newrelic_rpm'								                  # Performance Monitoring / Dyno keepalive
  gem 'dalli'										                      # enable memcache for heroku
  gem 'memcachier'									                  # use memcachier addon for heroku through dalli
  gem 'rack-ssl-enforcer'                             # reroutes all traffic through ssl
end

group :staging do
  gem 'slim'                                          # this is for sidekiq monitoring server 
  gem 'sinatra', :require => nil                      # this is for sidekiq monitoring server
end

# Gems used only for assets and not required in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'                      # required for twitter bootsrap
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails', :git => 'https://github.com/seyhunak/twitter-bootstrap-rails.git', :branch => 'bootstrap3'
  gem 'jquery-rails'
  gem 'jquery_mobile_rails', '~> 1.4.2'               # mobile UI bootstrap
end



