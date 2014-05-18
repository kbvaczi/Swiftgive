class ContactMailer < ActionMailer::Base
 
  default :from => "\"Swiftgive\" <noreply@swiftgive.com>"

  def send_mail(sender)
    @sender = sender

    mail(:to => "noreply@swiftgive.com",
         :subject => "Contact Form: #{sender.support_type}")
  end
  
end
