ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtpout.secureserver.net',
  :port => 80,
  :domain => "swiftgive.com",
  :user_name => 'noreply@swiftgive.com',
  :password => ENV['EMAIL_PASSWORD'],
  :authentication => :plain,
  :from => "\"SwiftGive Notifications\" <noreply@SwiftGive.com>"
}