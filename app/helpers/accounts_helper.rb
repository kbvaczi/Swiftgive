module AccountsHelper

	def display_accountholder_name(account, is_anonymous)
		if is_anonymous
			"<span class='muted'>Anonymous</span>".html_safe
		else
			account.full_name
		end
	end

end