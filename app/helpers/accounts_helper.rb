module AccountsHelper

	def display_accountholder_name(user, is_anonymous)
		if is_anonymous
			"<span class='muted'>Anonymous</span>".html_safe
		else
			user.account.full_name
		end
	end

end