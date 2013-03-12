source 'https://rubygems.org'

gem 'rails', '3.2.12'
gem "skeleton-rails", "~> 0.0.2"                      # Grid 960 CSS foundation

gem "devise", "~> 2.2.3"                              # User Authentication
gem "omniauth", "~> 1.1.3"                            # omni-auth implementation for signing in from third party services (facebook, google, etc...)
gem "omniauth-facebook", "~> 1.4.1"                   # omni-auth plugin for logging in from facebook
gem "omniauth-google-oauth2", "~> 0.1.13"             # omni-auth strategy for logging in with google

gem 'unicorn'                                         # Multi-threaded web server                                         

group :development do
  gem 'hooves', :require => 'hooves/default'          # unicorn works with "rails s"
  gem 'sqlite3'                                       # simple file-based database
end

# Gems used only for assets and not required in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

