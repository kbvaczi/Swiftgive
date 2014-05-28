module PaymentsHelper

	def current_user_payments_made_today
		current_user.payments.where('payments.created_at > ?', Time.zone.today.beginning_of_day)
	end		

	def current_user_payments_made_this_month
		current_user.payments.where('payments.created_at > ?', Time.zone.today.beginning_of_month)
	end

	def current_user_amount_payments_today_in_cents
		current_user.payments.where('payments.created_at > ?', Time.zone.today.beginning_of_day).sum(:amount_in_cents)
	end

	def current_user_amount_payments_this_month_in_cents
		current_user.payments.where('payments.created_at > ?', Time.zone.today.beginning_of_month).sum(:amount_in_cents)
	end

	def current_user_payments_received_today
		current_user.payments_received.where('payments.created_at > ?', Time.zone.today.beginning_of_day)
	end

	def current_user_payments_received_this_month
		current_user.payments_received.where('payments.created_at > ?', Time.zone.today.beginning_of_month)
	end

	def current_user_amount_payments_received_today_in_cents
		current_user.payments_received.where('payments.created_at > ?', Time.zone.today.beginning_of_day).sum(:amount_in_cents)
	end

	def current_user_amount_payments_received_this_month_in_cents
		current_user.payments_received.where('payments.created_at > ?', Time.zone.today.beginning_of_month).sum(:amount_in_cents)
	end

end