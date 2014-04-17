module AccountsHelper

	def display_accountholder_name(account, is_anonymous)
		if is_anonymous
			"<span class='muted'>Anonymous</span>".html_safe
		else
			account.full_name
		end
	end

	def display_accountholder_location(account)
		display_location = ""
		display_location += "#{account.city.capitalize}" if account.city.present?
		display_location += ", " if account.city.present? && account.state.present?
	end

end