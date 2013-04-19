# Be sure to restart your server when you modify this file.

# Use cookie-based session storage
# Swiftgive::Application.config.session_store :cookie_store, key: '_swiftgive_session'

# Use memcache session storage
Rails.application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 20.minutes

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Swiftgive::Application.config.session_store :active_record_store
