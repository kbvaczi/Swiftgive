IMGKit.configure do |config|
  if ENV['RACK_ENV'] == 'production' or ENV['RACK_ENV'] == 'staging'
	  config.wkhtmltoimage = Rails.root.join('bin', 'wkhtmltoimage-amd64').to_s 
	end
end