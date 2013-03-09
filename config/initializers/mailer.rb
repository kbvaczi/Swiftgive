ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => 'smtp.gmail.com',
  :port => 587,
  :domain => "swiftgive.com",
  :user_name => 'noreply@swiftgive.com',
  :password => ENV['EMAIL_PASSWORD'],
  :authentication => 'plain',
  :from => "\"SwiftGive Notification\" <noreply@SwiftGive.com>"
}
