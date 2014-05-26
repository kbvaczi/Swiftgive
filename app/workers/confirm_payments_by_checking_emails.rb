class ConfirmPaymentsByCheckingEmails

  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform

		Rails.logger.debug "task starting: scan payments email"

		initialize_imap_connection_to_email

		Mail.find(keys: ['NOT','SEEN']) do |message, imap, message_id| # works only with IMAP, not with POP3 (https://github.com/mikel/mail/issues/258)
			payment_uid_from_email = message.body.decoded[/your payment id is: (\S+)/i,1]
			this_payment = Payment.unconfirmed.where(:uid => payment_uid_from_email).first
			if this_payment.present?
				puts "Payment #{payment_uid_from_email} Found"
				sender_address    = message.from.first
				sender_name       = message[:from].decoded[/(.+) \</, 1]
				to_addresses      = message.to
				cc_addresses      = message.cc
				subject           = message.subject
				amount_in_cents   = (subject[/( |^)\$(\d+\.?\d{,2})( |$)/, 2].to_f * 100).to_i # there must be spaces around dollar amount for square cash to recognize 
				this_payment.confirm_by_email(sender_address, sender_name, to_addresses, cc_addresses, subject, amount_in_cents)
				imap.uid_store(message_id, "+FLAGS", [:Seen]) # mark messages as read (https://github.com/mikel/mail/issues/422)
			end
		end

		# cancel old payments that have no payment email sent
		Payment.cancel_old_payments

		Rails.logger.debug "task ending: scan payments email"    

  end

  def initialize_imap_connection_to_email
		Mail.defaults do
			retriever_method :imap, :address => 'imap.secureserver.net',
				:port       => 993,
				:user_name  => ENV['PAYMENTS_EMAIL'],
				:password   => ENV['PAYMENTS_EMAIL_PASSWORD'],
				:enable_ssl => true
		end
  end

end