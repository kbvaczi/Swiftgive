module FundsHelper

def display_description_with_line_breaks(description)
	strip_tags(description).gsub("\r\n", '<br/>').html_safe
end


end
