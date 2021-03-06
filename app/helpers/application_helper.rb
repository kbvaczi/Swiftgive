module ApplicationHelper

  def title(page_title, heading=true)
    provide :title, " | #{page_title.gsub(/[\[\]\^\$\.\|\?\*\+\\~`\!@#%\+={}'"<>;,]{1,}/, "").gsub("&", "and").capitalize}"
    if heading
      provide :page_title, page_title 
    end
  end
  
  def page_description(page_description = nil)
    provide :description, page_description
  end
  
  def display_time(time, options = {})
    if options[:day] == false
      day = nil
    else
      day = time.day.ordinalize
    end
    if options[:format] == 'long'
      time.strftime("%B #{day}, %Y")
    elsif options[:format] == 'spelled'
      time.strftime("%B %Y")
    else
      time.strftime("%m/%d/%y")
    end
  end

  def display_location(model)
    display_location = ""
    display_location += "#{model.city.capitalize}" if model.city.present?
    display_location += ", #{model.state}" if model.city.present? && model.state.present?
  end
  
  def us_state_codes_collection
    Carmen::Country.coded('US').subregions.collect { |s| s.code }.sort
  end
  
  def pretty_print_hash(input_hash)
    output_string = ""
    if input_hash.class == Hash
      input_hash.each do |key, value|
        if value.class == Hash
          output_string << "<strong>:#{key} =></strong><div style=\"margin-left:3%\">"
          output_string << pretty_print_hash(value)
          output_string << "</div>"
        elsif value.class == Array
          output_string << "<div style=\"margin-left:3%\">"
          value.each {|v| output_string << ("[" + pretty_print_hash(v) + "]<br/>")}
          output_string << "</div>"
        else
          output_string << "<div><strong>:#{key} =></strong> #{value}</div>"
        end
      end
    else
      output_string << input_hash.inspect
    end
    output_string.html_safe
  end

  def s3_image_path(path_within_images_directory)
    current_bucket = ENV['AWS_BUCKET']
    s3_image_path = "https://#{current_bucket}.s3.amazonaws.com/images/#{path_within_images_directory}"
    s3_image_path
  end
    
end


