class ContactMailer < ActionMailer::Base

	layout 'email'

	default :from => "\"Swiftgive\" <noreply@swiftgive.com>"

	def send_mail(sender)
		@sender = sender

		mail(:to => "admin@swiftgive.com", :subject => "Contact Form: #{sender.support_type}")
		#mail(:to => "kvaczi@gmail.com", :subject => "Contact Form: #{sender.support_type}")
	end
  
end
