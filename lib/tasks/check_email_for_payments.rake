# scans payments email to confirm payments.  reads unread mail, scans for payment details, updates in database, then marks mail as read.

desc "check email for payments"

task :check_email_for_payments => :environment do

	Rails.logger.debug "task starting: scan payments email"

	Mail.defaults do
	  retriever_method :imap, :address    => "imap.secureserver.net",
	                          :port       => 993,
	                          :user_name  => ENV['PAYMENTS_EMAIL'],
	                          :password   => ENV['PAYMENTS_EMAIL_PASSWORD'],
	                          :enable_ssl => true
	end
	
	Mail.find(keys: ['NOT','SEEN']) do |message, imap, message_id| # works only with IMAP, not with POP3 (https://github.com/mikel/mail/issues/258)
		payment_uid_from_email = message.body.decoded[/your payment id is: (\S+)/i,1]
		this_payment = Payment.unconfirmed.where(:uid => payment_uid_from_email).first
		if this_payment.present?
			Rails.logger.info "Payment #{payment_uid_from_email} Found" 
			this_payment.confirm_by_email(message) if this_payment.present?
			imap.uid_store(message_id, "+FLAGS", [:Seen]) # mark messages as read (https://github.com/mikel/mail/issues/422)
		end
	end

	Rails.logger.debug "task ending: scan payments email"

end