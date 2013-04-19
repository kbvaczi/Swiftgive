source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.12'
gem "skeleton-rails", "~> 0.0.2"                      # Grid 960 CSS foundation
gem "mobylette", "~> 3.3.2"                           # adds mobile mime type and ability to display separate mobile views

gem "devise", "~> 2.2.3"                              # User Authentication
gem "omniauth", "~> 1.1.3"                            # omni-auth implementation for signing in from third party services (facebook, google, etc...)
gem "omniauth-facebook", "~> 1.4.1"                   # omni-auth plugin for logging in from facebook
gem "omniauth-google-oauth2", "~> 0.1.13"             # omni-auth strategy for logging in with google
gem "omniauth-linkedin", "~> 0.1.0"                   # omni-auth strategy for logging in with linkedin

gem "balanced", "~> 0.7.0"                            # balanced payments gateway

gem "rqrcode", "~> 0.4.2"                             # QRCode Generator Library

gem "carmen", "~> 1.0.0.beta2"
#gem "carmen-rails", "~> 1.0.0.beta3"                  # country and state information

gem 'unicorn'                                         # Multi-threaded web server

group :development do
  gem 'hooves', :require => 'hooves/default'          # unicorn works with "rails s"
  gem 'sqlite3'                                       # simple file-based database
end

group :staging, :production do
  gem "activerecord-postgresql-adapter"               # PostgesQL Adapter for Heroku Database
  gem 'newrelic-rpm'								  # Performance Monitoring / Dyno keepalive
  gem 'dalli'										  # enable memcache for heroku
  gem 'memcachier'									  # use memcachier addon for heroku through dalli
  gem 'rack-www'									  # rack middleware to add www. to naked domain calls
end

# Gems used only for assets and not required in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem "jquery_mobile_rails", "~> 1.3.0"

